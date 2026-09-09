-- https://wiki.hyprland.org/Configuring/
--
-- Declarative modules take effect as they load. Those owning state, timers or
-- subscriptions expose setup(), so requiring them alone does nothing.

UTIL = require("hyprland.util")

-- Monitors before clamshell: the externals must exist before clamshell first
-- asks whether any are connected.
require("hyprland.monitors").setup()
require("hyprland.clamshell").setup()

-- Per-machine additions outside the config schema.
require("hyprland.local")

require("hyprland.scratch").setup()

require("hyprland.keybindings")
require("hyprland.windows")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.tiling")
require("hyprland.look")

require("hyprland.battery").setup()
