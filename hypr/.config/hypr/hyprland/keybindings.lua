--------------------------------------------------------------------------------
---                               KEYBINDINGS                                ---
--------------------------------------------------------------------------------

-- See https://wiki.hyprland.org/Configuring/Keywords/
local terminal    = "uwsm app -- xdg-terminal-exec"
local fileManager = "uwsm app -- xdg-open " .. os.getenv("HOME")
local configHome  = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")

local util        = require("lib.util")
local b           = require("lib.bind")
--------------------------------------------------------------------------------
---                                  SHELL                                   ---
--------------------------------------------------------------------------------

---@type Actions
local shell       = require("lib.shell")

b.bind({ b.SPR }, "N", shell.open_notification, "Show notification history")
b.bind({ b.SPR }, "comma", shell.open_settings, "Show Settings")

b.bind({}, "XF86AudioRaiseVolume", shell.volume_raise, "Increase volume", { repeating = true, locked = true })
b.bind({}, "XF86AudioLowerVolume", shell.volume_lower, "Decrease volume", { repeating = true, locked = true })
b.bind({}, "XF86AudioMute", shell.volume_mute, "Mute volume", { locked = true })
b.bind({}, "XF86AudioMicMute", shell.mic_mute, "Mute microphone", { locked = true })
b.bind({}, "XF86MonBrightnessUp", shell.brightness_inc, "Increase brightness", { repeating = true, locked = true })
b.bind({}, "XF86MonBrightnessDown", shell.brightness_dec, "Decrease brightness", { repeating = true, locked = true })

-- Playerctl media keys
b.bind({}, "XF86AudioNext", shell.next, "Skip next", { locked = true })
b.bind({}, "XF86AudioPrev", shell.prev, "Skip prev", { locked = true })
b.bind({}, "XF86AudioPause", shell.play_pause, "Toggle play/pause", { locked = true })
b.bind({}, "XF86AudioPlay", shell.play_pause, "Toggle play/pause", { locked = true })

b.bind({ b.CTRL, b.ALT }, "right", shell.next, "Skip next", { locked = true })
b.bind({ b.CTRL, b.ALT }, "left", shell.prev, "Skip prev", { locked = true })
b.bind({ b.CTRL, b.ALT }, "Space", shell.play_pause, "Toggle play/pause", { locked = true })

-- Session management
b.bind({ b.SPR }, "escape", shell.lock, "Lock screen")
b.bind({ b.SPR }, "Delete", shell.powermenu, "Power Menu")

--------------------------------------------------------------------------------
---                               COMMON BINDS                               ---
--------------------------------------------------------------------------------

b.bind({ b.SPR, b.SHFT }, "Q", hl.dsp.window.close(), "Close active window")
b.bind({ b.SPR }, "return", hl.dsp.exec_cmd(terminal), "Launch terminal")
b.bind({ b.SPR }, "E", hl.dsp.exec_cmd(fileManager), "Launch FileManager")
b.bind({ b.SPR }, "D", hl.dsp.exec_cmd("walker"), "Open Launcher")
b.bind({ b.SPR }, "B", hl.dsp.exec_cmd("walker -m bookmarks"), "Open Launcher")
b.bind({ b.SPR, b.SHFT }, "B", hl.dsp.exec_cmd("walker -m bluetooth"), "Manage Bluetooth")

b.bind({ b.SPR, b.SHFT }, "F", hl.dsp.window.float(), "Toggle floating")
b.bind({ b.SPR }, "P", hl.dsp.window.pseudo(), "Toggle Pseudo tiling")
b.bind({ b.SPR }, "O", hl.dsp.layout("togglesplit"), "Toggle split direction")

b.bind({ b.SPR }, "F", hl.dsp.window.fullscreen(0), "Toggle fullscreen")
b.bind({ b.SPR, b.CTRL }, "F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }),
  "Tiled full screen")
-- TODO: Fix maximise
b.bind({ b.SPR }, "M", hl.dsp.window.fullscreen(1), "Toggle maximation")

b.bind({ b.SPR }, "G", hl.dsp.group.toggle(), "Toggle group mode")
b.bind({ b.SPR, b.SHFT }, "G", hl.dsp.group.next(), "Change active window in group")

-- Move focus with SUPER + arrow keys
for i, dir in ipairs({ "left", "right", "up", "down" }) do
  local vim_key = ({ "h", "l", "k", "j" })[i]

  b.bind({ b.SPR }, { dir, vim_key }, hl.dsp.focus({ direction = dir }), "Move focus " .. dir)
  b.bind({ b.SPR, b.SHFT }, { dir, vim_key }, hl.dsp.window.move({ direction = dir }), "Move window " .. dir)

  local resize_dir = ({ { -30, 0 }, { 30, 0 }, { 0, -30 }, { 0, 30 } })[i]
  local arg = { x = resize_dir[1], y = resize_dir[2], relative = true }
  b.bind({ b.SPR, b.CTRL }, { dir, vim_key }, hl.dsp.window.resize(arg), "Resize " .. dir, { repeating = true })
end

-- Switch / move to workspaces
for i = 1, 10 do
  local key = i % 10
  b.bind({ b.SPR }, tostring(key), hl.dsp.focus({ workspace = i }), "Switch to workspace " .. i)
  b.bind({ b.SPR, b.SHFT }, tostring(key), hl.dsp.window.move({ workspace = i }), "Move to workspace " .. i)
end

-- Toggle scratchpad
b.bind({ b.SPR }, { "Q", "S" }, hl.dsp.workspace.toggle_special("scratch"), "Toggle scratchpad shown")

-- Center and resize to 80% of current screen
b.bind({ b.SPR }, "C", util.ResizePercent(0.8, 0.8, true), "Center floating window")

-- Scroll through existing workspaces
-- TODO: FIX
b.bind({ b.SPR }, "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
b.bind({ b.SPR }, "mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
b.bind({ b.SPR }, "mouse:272", hl.dsp.window.drag(), "Move window with left mouse", { mouse = true })
b.bind({ b.SPR }, "mouse:273", hl.dsp.window.resize(), "Resize window with right mouse", { mouse = true })

b.bind({}, "Print", hl.dsp.exec_cmd("flameshot gui"), "Take area screenshot")

-- Theme related
b.bind({ b.SPR, b.SHFT }, "comma", hl.dsp.exec_cmd("theme_menu"), "Open theme menu")

b.bind({ b.SPR, b.ALT }, "k", hl.dsp.exec_cmd(configHome .. "/hypr/hyprland/scripts/keymap_hint.sh"),
  "Show all keybindings")
