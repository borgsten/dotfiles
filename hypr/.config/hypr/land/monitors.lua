--------------------------------------------------------------------------------
---                                 MONITORS                                 ---
--------------------------------------------------------------------------------

---@class Config.Monitors
---@field external HL.MonitorSpec[]
---@field internal? HL.MonitorSpec

local M = {}

function M.setup()
  local cfg = UTIL.config.section("monitors", { external = {} })

  for _, spec in ipairs(cfg.external) do
    UTIL.output.apply(spec)
  end

  if cfg.internal == nil then return end

  -- Clamshell owns the internal output when enabled; applying it here too
  -- would fight it. The contract is the config section, not the module.
  local clamshell = UTIL.config.section("clamshell", { enabled = false })
  if not clamshell.enabled then
    UTIL.output.apply(cfg.internal)
  end
end

return M
