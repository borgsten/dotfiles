-- https://wiki.hyprland.org/Configuring/

-- Read logs from "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
-- hl.config({
--   debug = { disable_logs = false }
-- })

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
