---@class ClamshellConfig
---@field enabled boolean
---@field lid_switch string      switch name (`hyprctl devices`)

---@class Config
---@field external_monitors HL.MonitorSpec[]
---@field internal? HL.MonitorSpec
---@field clamshell? ClamshellConfig

local M = {}

-- Load the per-machine (gitignored) config table. Returns nil if absent,
-- so the entrypoint can degrade gracefully on a fresh checkout.
---@return Config?
function M.load()
  local ok, cfg = pcall(require, "hyprland.local.config")
  if not ok then
    return nil
  end
  ---@cast cfg Config
  return cfg
end

return M
