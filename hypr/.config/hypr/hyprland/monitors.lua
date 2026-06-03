local M = {}

---@param cfg Config
function M.setup(cfg)
  assert(cfg.external_monitors, "monitors: 'external_monitors' list is required")

  for _, m in ipairs(cfg.external_monitors) do
    hl.monitor(m)
  end

  if cfg.internal then
    if cfg.clamshell and cfg.clamshell.enabled == true then
      require("clamshell").setup(cfg)
    else
      hl.monitor(cfg.internal)
    end
  end
end

return M
