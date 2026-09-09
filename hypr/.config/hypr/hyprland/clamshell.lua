--------------------------------------------------------------------------------
---                                CLAMSHELL                                 ---
--------------------------------------------------------------------------------
--- Internal display off when the lid is shut *and* an external is attached,
--- so closing the lid on a bare laptop never blanks the session.

---@class Config.Clamshell
---@field enabled boolean
---@field lid_switch string  switch name, from `hyprctl devices`

local M = {}

local dbg = UTIL.dbg

--- From /proc rather than remembered: the Lua state is rebuilt each reload.
---@return boolean
local function readLidClosed()
  for _, path in ipairs(UTIL.sys.glob("/proc/acpi/button/lid/*/state")) do
    local content = UTIL.sys.readFile(path)
    if content then return content:match("closed") ~= nil end
  end
  return false
end

function M.setup()
  local cfg = UTIL.config.section("clamshell", { enabled = false })
  if not cfg.enabled then return end

  -- Misconfiguration disables the feature rather than asserting, which would
  -- abort the whole evaluation and take the session's keybinds with it.
  local monitors = UTIL.config.section("monitors", { external = {} })
  if monitors.internal == nil then
    UTIL.notif.osd("clamshell: enabled, but monitors.internal is not set")
    return
  end
  if cfg.lid_switch == nil then
    UTIL.notif.osd("clamshell: enabled, but clamshell.lid_switch is not set")
    return
  end

  local internal = monitors.internal
  local internal_on = UTIL.output.override(internal, { disabled = false })
  local internal_off = UTIL.output.override(internal, { disabled = true })

  local lid_closed = readLidClosed()

  local function apply()
    local external_connected = #UTIL.output.othersThan(internal.output) > 0
    local want_off = lid_closed and external_connected
    UTIL.output.apply(want_off and internal_off or internal_on)
  end

  hl.bind("switch:on:" .. cfg.lid_switch, function()
    lid_closed = true
    dbg.trace("clamshell: lid closed, internal OFF if external connected")
    apply()
  end, { locked = true })

  hl.bind("switch:off:" .. cfg.lid_switch, function()
    lid_closed = false
    dbg.trace("clamshell: lid opened, internal ON")
    apply()
  end, { locked = true })

  hl.on("monitor.added", function()
    dbg.trace("clamshell: monitor added, re-evaluating")
    apply()
  end)

  hl.on("monitor.removed", function()
    dbg.trace("clamshell: monitor removed, re-evaluating")
    apply()
  end)

  hl.on("hyprland.start", function()
    dbg.trace("clamshell: hyprland.start, re-evaluating")
    apply()
  end)

  dbg.trace("clamshell: setup, evaluating internal state")
  apply()
end

return M
