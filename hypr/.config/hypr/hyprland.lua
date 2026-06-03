-- https://wiki.hyprland.org/Configuring/

-- Read logs from "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
-- hl.config({
--   debug = { disable_logs = false }
-- })

local config = require("lib.config").load()
if config then
  require("hyprland.monitors").setup(config)
end

require("hyprland.local")

require("hyprland.env")
require("hyprland.startup")
require("hyprland.keybindings")
require("hyprland.windows")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.tiling")
require("hyprland.look")

require("hyprland.battery")
