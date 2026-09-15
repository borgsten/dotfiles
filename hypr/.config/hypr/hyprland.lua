-- https://wiki.hyprland.org/Configuring/
--
-- Declarative modules take effect as they load. Those owning state, timers or
-- subscriptions expose setup(), so requiring them alone does nothing.

UTIL = require("land.util")

-- Monitors before clamshell: the externals must exist before clamshell first
-- asks whether any are connected.
require("land.monitors").setup()
require("land.clamshell").setup()

-- Per-machine additions outside the config schema.
require("land.local")

require("land.scratch").setup()

require("land.keybindings")
require("land.windows")
require("land.input")
require("land.misc")
require("land.tiling")
require("land.look")

require("land.battery").setup()
