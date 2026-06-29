-- hyprland/monitors.lua
--
-- Entry point for monitor configuration. Per-machine specs come in via the
-- local (gitignored) config; this module only decides ordering and delegates
-- the actual apply to lib.monitor so reloads don't re-modeset monitors that
-- are already in the right state.

local mon = require("lib.monitor")

local M = {}

---@param cfg Config
function M.setup(cfg)
  assert(cfg.external_monitors, "monitors: 'external_monitors' list is required")

  -- Idempotent: on a reload the dock is already configured, so this no-ops
  -- instead of forcing a modeset (which is what caused the black flash).
  for _, spec in ipairs(cfg.external_monitors) do
    mon.apply(spec)
  end

  if cfg.internal then
    if cfg.clamshell and cfg.clamshell.enabled == true then
      -- Clamshell owns the internal output entirely (enable/disable on lid).
      require("hyprland.clamshell").setup(cfg)
    else
      mon.apply(cfg.internal)
    end
  end
end

return M
