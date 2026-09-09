--- The shape of `hyprland/local/config.lua` (per-machine, gitignored).
---
--- Nothing requires this at runtime: it exists so lua_ls can resolve
--- `---@type Config` there. Each feature module declares its own
--- `---@class Config.X` next to the defaults it owns; this composes them.

---@class Config
---@field shell? Config.Shell
---@field monitors? Config.Monitors
---@field clamshell? Config.Clamshell
---@field battery? Config.Battery
---@field scratchpads? table<string, Config.Scratchpad>

return {}
