-- https://wiki.hyprland.org/Configuring/

-- debug:disable_logs = false

require("hyprland.env")
require("hyprland.startup")
require("hyprland.keybindings")
require("hyprland.windows")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.tiling")
require("hyprland.look")

-- Setup clamshell after local overrides to pick up screen variables
require("hyprland.clamshell")
require("hyprland.battery")

require("hyprland.local")
