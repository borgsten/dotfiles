-- Lazily loads hyprland.util.<key> on first access, as the global UTIL.
--
-- _G.UTIL is assigned *before* any submodule is required, so submodules can
-- reference UTIL.xxx for their own cross-deps regardless of load order.

local ALIASES = {
  dbg        = "debug",
  notif      = "notif",
  helpers    = "helpers",
  bind       = "bind",
  config     = "config",
  output     = "output",
  sys        = "sys",
  cmd        = "cmd",
  tbl        = "tbl",
  scratchpad = "scratchpad",
  watch      = "watch",
}

---Type hints only: these resolve UTIL.dbg etc. to the real submodule class
---without require-ing anything at runtime. Keep in sync with ALIASES.
---@class Util
---@field dbg Util.Debug
---@field notif Util.Notif
---@field helpers Util.Helpers
---@field bind Util.Bind
---@field config Util.Config
---@field output Util.Output
---@field sys Util.Sys
---@field cmd Util.Cmd
---@field tbl Util.Tbl
---@field scratchpad Util.Scratchpad
---@field watch Util.Watch
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
