-- https://wiki.hyprland.org/Configuring/

local config = require("lib.config").load()
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
