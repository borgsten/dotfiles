local M = {}

---@param cfg Config
function M.setup(cfg)
  assert(cfg.internal, "clamshell: 'internal' is required")
  assert(cfg.clamshell.enabled, "clamshell: setup called but not enabled")
  assert(cfg.clamshell.lid_switch, "clamshell: 'lid_switch' is required")

  local internal_enabled = cfg.internal or {}
  internal_enabled.disabled = false

  local internal_name = cfg.internal.output

  local lid_closed = false

  ---@return boolean
  local function external_connected()
    for _, m in ipairs(hl.get_monitors()) do
      if m.name ~= internal_name then
        return true
      end
    end
    return false
  end

  local function apply()
    if lid_closed and external_connected() then
      hl.monitor({ output = internal_name, disabled = true })
    else
      hl.monitor(internal_enabled)
    end
  end

  hl.bind("switch:off:" .. cfg.clamshell.lid_switch, function()
    lid_closed = true
    apply()
  end, { locked = true })
  hl.bind("switch:on:" .. cfg.clamshell.lid_switch, function()
    lid_closed = false
    apply()
  end, { locked = true })

  hl.on("monitor.added", apply)
  hl.on("monitor.removed", apply)
  hl.on("hyprland.start", apply)
end

return M
