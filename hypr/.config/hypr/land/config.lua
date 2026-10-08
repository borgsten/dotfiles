--- The shape of `land/local/config.lua` (per-machine, gitignored).
---
--- Nothing requires this at runtime: it exists so lua_ls can resolve
--- `---@type Config` there. Each feature module declares its own
--- `---@class Config.X` next to the defaults it owns; this composes them.
---
--- `Config.X` is the resolved shape, after the defaults are merged in. A
--- machine only states what it changes, so each section here is a `(partial)`
--- subclass: inherited fields are never reported as missing.

---@class (partial) Config.Local.Shell: Config.Shell
---@class (partial) Config.Local.Clamshell: Config.Clamshell
---@class (partial) Config.Local.Battery: Config.Battery
---@class (partial) Config.Local.Presenting: Config.Presenting

---@class (partial) Config.Local.Monitors: Config.Monitors
---@field fallback? Config.Local.MonitorSpec  merged over the default, so `output` may be left out

---@class (partial) Config.Local.MonitorSpec: Config.MonitorSpec

---@class Config
---@field shell? Config.Local.Shell
---@field monitors? Config.Local.Monitors
---@field clamshell? Config.Local.Clamshell
---@field battery? Config.Local.Battery
---@field presenting? Config.Local.Presenting
---@field scratchpads? table<string, Config.Scratchpad>

return {}
