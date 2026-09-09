-- Lazily loads hyprland.util.<key> submodules on first access and exposes
-- the result as the global UTIL table.
--
-- _G.UTIL is assigned *before* any submodule is required, so submodules
-- inside this directory (and everything else) can safely reference
-- UTIL.xxx for their own cross-deps, regardless of load order.

local ALIASES = {
  dbg     = "debug",
  notif   = "notif",
  helpers = "helpers",
  bind    = "bind",
  config  = "config",
  monitor = "monitor",
}

---Static type hints only -- these `@field` annotations let lua_ls resolve
---`UTIL.dbg` etc. to the real submodule's named class (declared via
---`---@class Util.X` above each module's `local M = {}`), enabling
---go-to-definition/autocomplete into the actual functions, without
---eagerly `require`-ing anything at runtime. Keep in sync with ALIASES.
---@class Util
---@field dbg Util.Debug
---@field notif Util.Notif
---@field helpers Util.Helpers
---@field bind Util.Bind
---@field config Util.Config
---@field monitor Util.Monitor
local M = setmetatable({}, {
  __index = function(t, key)
    local modname = ALIASES[key]
    if not modname then
      error(("UTIL.%s: no such util module"):format(tostring(key)), 2)
    end
    local mod = require("hyprland.util." .. modname)
    rawset(t, key, mod) -- cache so subsequent lookups skip require()
    return mod
  end,
})

_G.UTIL = M ---@type Util

return M
