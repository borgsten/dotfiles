local mon = require("lib.monitor")
local dbg = require("lib.debug")

local M = {}

---@param cfg Config
function M.setup(cfg)
  assert(cfg.internal, "clamshell: 'internal' is required")
  assert(cfg.clamshell and cfg.clamshell.enabled, "clamshell: setup called but not enabled")
  assert(cfg.clamshell.lid_switch, "clamshell: 'lid_switch' is required")

  local internal_name = cfg.internal.output

  -- Spec for the internal being ON: the user's spec with disabled cleared.
  local internal_on = {}
  for k, v in pairs(cfg.internal) do internal_on[k] = v end
  internal_on.disabled = false

  -- Spec for the internal being OFF.
  local internal_off = {}
  for k, v in pairs(cfg.internal) do internal_off[k] = v end
  internal_off.disabled = true

  local function read_lid_closed()
    for _, path in ipairs({
      "/proc/acpi/button/lid/LID0/state",
      "/proc/acpi/button/lid/LID/state",
    }) do
      local f = io.open(path, "r")
      if f then
        local content = f:read("*all")
        f:close()
        return content:match("closed") ~= nil
      end
    end
    return false
  end

  ---@return boolean
  local function external_connected()
    for _, m in ipairs(hl.get_monitors()) do
      if m.name ~= internal_name then
        return true
      end
    end
    return false
  end

  -- Fresh closure each reload (Lua state is rebuilt), re-seeded from /proc.
  -- Nothing here needs to persist across reloads.
  local lid_closed = read_lid_closed()

  local function apply()
    local want_off = lid_closed and external_connected()
    mon.apply(want_off and internal_off or internal_on)
  end

  hl.bind("switch:on:" .. cfg.clamshell.lid_switch, function()
    lid_closed = true
    dbg.trace("clamshell: lid closed, internal OFF if external connected")
    apply()
  end, { locked = true })

  hl.bind("switch:off:" .. cfg.clamshell.lid_switch, function()
    lid_closed = false
    dbg.trace("clamshell: lid opened, internal ON")
    apply()
  end, { locked = true })

  hl.on("monitor.added", function(test)
    dbg.trace("clamshell: monitor added, re-evaluating internal state", test)
    apply()
  end)
  --- This event fires when internal is disabled but will not be applied again
  hl.on("monitor.removed", function(test)
    dbg.trace("clamshell: monitor removed, re-evaluating internal state", test)
    apply()
  end)

  hl.on("hyprland.start", function()
    dbg.trace("clamshell: hyprland.start, re-evaluating internal state")
    apply()
  end)

  dbg.trace("clamshell: setup() called, re-evaluating internal state")
  apply()
end

return M
