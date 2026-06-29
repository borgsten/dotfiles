-- hyprland/clamshell.lua
--
-- When the lid closes AND an external monitor is connected, disable the
-- internal output. Disabling (not DPMS-off) is deliberate: it removes the
-- output from the set Hyprland keeps a workspace bound to, so Hyprland
-- relocates the internal's workspace to the external as part of the teardown.
--
-- We do NOT migrate windows/workspaces by hand. Hyprland guarantees every
-- *enabled* monitor has an active workspace, so any manual migration leaves
-- exactly one workspace behind (Hyprland re-binds one the instant the last
-- leaves). Letting disable do the relocation is the only way to fully clear
-- the internal.
--
-- Every monitor change goes through lib.monitor.apply, which no-ops when the
-- live state already matches. That makes a "docked + closed" reload issue
-- zero modesets, which is what stops the external from black-flashing.

local mon = require("lib.monitor")

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
  local internal_off = { output = internal_name, disabled = true }

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
    -- Idempotent: only modesets when the internal isn't already in the
    -- desired state. Disable handles workspace relocation; no manual moves.
    mon.apply(want_off and internal_off or internal_on)
  end

  hl.bind("switch:on:" .. cfg.clamshell.lid_switch, function()
    lid_closed = true
    apply()
  end, { locked = true })

  hl.bind("switch:off:" .. cfg.clamshell.lid_switch, function()
    lid_closed = false
    apply()
  end, { locked = true })

  -- Hotplug: dock connect/disconnect changes the want_off decision.
  hl.on("monitor.added", apply)
  hl.on("monitor.removed", apply)

  -- Boot: fires after outputs are enumerated, so external_connected() is real.
  hl.on("hyprland.start", apply)

  -- Reload reconcile: this whole file re-executes on reload (confirmed: the
  -- Lua state resets), so setup() running *is* the reload signal. Reconcile
  -- now. On boot this also runs, before enumeration, but it can only ever
  -- decide "keep internal on", which is a no-op against the already-up panel —
  -- hyprland.start then does the real reconcile once externals appear.
  apply()
end

return M
