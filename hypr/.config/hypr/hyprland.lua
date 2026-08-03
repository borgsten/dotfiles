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
hl.window_rule({
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  size = { "monitor_w * 0.8", "monitor_h * 0.8" },
})
