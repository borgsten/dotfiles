--------------------------------------------------------------------------------
---                               KEYBINDINGS                                ---
--------------------------------------------------------------------------------

-- See https://wiki.hyprland.org/Configuring/Keywords/
local mainMod      = "SUPER"
local terminal     = "uwsm app -- xdg-terminal-exec"
local fileManager  = "uwsm app -- xdg-open " .. os.getenv("HOME")
local configHome   = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")

--------------------------------------------------------------------------------
---                                  SHELL                                   ---
--------------------------------------------------------------------------------

---@type Actions
local shell_action = require("lib.shell")

hl.bind(mainMod .. " + N", shell_action.open_notification, { desc = "Show notification history" })
hl.bind(mainMod .. " + comma", shell_action.open_settings, { desc = "Show Settings" })

hl.bind("XF86AudioRaiseVolume", shell_action.volume_raise,
  { desc = "Increase volume", repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", shell_action.volume_lower,
  { desc = "Decrease volume", repeating = true, locked = true })
hl.bind("XF86AudioMute", shell_action.volume_mute, { desc = "Mute volume", locked = true })
hl.bind("XF86AudioMicMute", shell_action.mic_mute, { desc = "Mute microphone", locked = true })
hl.bind("XF86MonBrightnessUp", shell_action.brightness_inc,
  { desc = "Increase brightness", repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", shell_action.brightness_dec,
  { desc = "Decrease brightness", repeating = true, locked = true })

-- Playerctl media keys
hl.bind("XF86AudioNext", shell_action.next, { desc = "Skip next", locked = true })
hl.bind("XF86AudioPrev", shell_action.prev, { desc = "Skip prev", locked = true })
hl.bind("XF86AudioPause", shell_action.play_pause, { desc = "Toggle play/pause", locked = true })
hl.bind("XF86AudioPlay", shell_action.play_pause, { desc = "Toggle play/pause", locked = true })

hl.bind("CONTROL + ALT + right", shell_action.next, { desc = "Skip next", locked = true })
hl.bind("CONTROL + ALT + left", shell_action.prev, { desc = "Skip prev", locked = true })
hl.bind("CONTROL + ALT + Space", shell_action.play_pause, { desc = "Toggle play/pause", locked = true })

-- Session management
hl.bind(mainMod .. " + escape", shell_action.lock, { desc = "Lock screen" })
hl.bind(mainMod .. " + Delete", shell_action.powermenu, { desc = "Power Menu" })

--------------------------------------------------------------------------------
---                               COMMON BINDS                               ---
--------------------------------------------------------------------------------

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill(), { desc = "Kill active window" })
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal), { desc = "Launch terminal" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { desc = "Launch FileManager" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("walker"), { desc = "Open Launcher" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("walker -m bookmarks"), { desc = "Open Launcher" })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("walker -m bluetooth"), { desc = "Manage Bluetooth" })

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float(), { desc = "Toggle floating" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { desc = "Toggle Pseudo tiling" })
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"), { desc = "Toggle split direction" })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(0), { desc = "Toggle fullscreen" })
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }),
  { desc = "Tiled full screen" })
-- TODO: Fix maximise
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen(1), { desc = "Toggle maximation" })

hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { desc = "Toggle group mode" })
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.next(), { desc = "Change active window in group" })

-- Move focus with mainMod + arrow keys
for i, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }), { desc = "Move focus " .. dir })
  hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), { desc = "Move window " .. dir })

  local vim_key = ({ "h", "l", "k", "j" })[i]
  hl.bind(mainMod .. " + " .. vim_key, hl.dsp.focus({ direction = dir }), { desc = "Move focus " .. dir })
  hl.bind(mainMod .. " + SHIFT + " .. vim_key, hl.dsp.window.move({ direction = dir }), { desc = "Move window " .. dir })

  local resize_dir = ({ { -30, 0 }, { 30, 0 }, { 0, -30 }, { 0, 30 } })[i]
  local arg = { x = resize_dir[1], y = resize_dir[2], relative = true }
  hl.bind(mainMod .. " + CONTROL + " .. dir, hl.dsp.window.resize(arg), { desc = "Resize " .. dir, repeating = true })
  hl.bind(mainMod .. " + CONTROL + " .. vim_key, hl.dsp.window.resize(arg), { desc = "Resize " .. dir, repeating = true })
end

-- Switch / move to workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { desc = "Switch to workspace " .. i })
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { desc = "Move to workspace " .. i })
end

-- Toggle scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratch"), { desc = "Toggle scratchpad shown" })
hl.bind(mainMod .. " + Q", hl.dsp.workspace.toggle_special("scratch"), { desc = "Toggle scratchpad shown" })

-- Center and resize to 80% of current screen
hl.bind(mainMod .. " + C", function()
    hl.dispatch(hl.dsp.window.center())

    local mon = hl.get_active_monitor()
    if mon == nil then return end

    local w = math.floor(mon.width * 0.8)
    local h = math.floor(mon.height * 0.8)

    hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
  end,
  { desc = "Center floating window" })

-- Scroll through existing workspaces
-- TODO: FIX
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { desc = "Move window with left mouse", mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { desc = "Resize window with right mouse", mouse = true })

hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"), { desc = "Take area screenshot" })

-- Theme related
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("theme_menu"), { desc = "Open theme menu" })

hl.bind(mainMod .. " + ALT + k", hl.dsp.exec_cmd(configHome .. "/hypr/hyprland/scripts/keymap_hint.sh"),
  { desc = "Show all keybindings" })
