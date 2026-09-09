-- https://wiki.hyprland.org/Configuring/

UTIL = require("hyprland.util")

local config = UTIL.config.load()
if config then
  require("hyprland.monitors").setup(config)
end

require("hyprland.local")

require("hyprland.startup")
require("hyprland.keybindings")
require("hyprland.windows")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.tiling")
require("hyprland.look")

require("hyprland.battery")
