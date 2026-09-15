--------------------------------------------------------------------------------
---                                  SHELL                                   ---
--------------------------------------------------------------------------------
--- Actions that a desktop shell owns: volume, brightness, launcher, lock etc.
--- Expressed once as an interface and implemented per shell.

---@alias ShellType
---| "DMS"
---| "noctalia"
---| "bespoke"

---@class Config.Shell
---@field type? ShellType

---@alias ShellAction HL.Dispatcher|fun()

---@class Actions
---@field volume_raise      ShellAction
---@field volume_lower      ShellAction
---@field volume_mute       ShellAction
---@field mic_mute          ShellAction
---@field brightness_inc    ShellAction
---@field brightness_dec    ShellAction
---@field lock              ShellAction
---@field powermenu         ShellAction
---@field open_notification ShellAction
---@field open_settings     ShellAction
---@field next              ShellAction
---@field prev              ShellAction
---@field play_pause        ShellAction
---@field launcher          ShellAction
---@field bookmarks         ShellAction
---@field bluetooth         ShellAction

local dms         = UTIL.cmd.prefixed("dms ipc call")
local noctalia    = UTIL.cmd.prefixed("noctalia msg")
local swayosd     = UTIL.cmd.perMonitor("swayosd-client --monitor")
local raw         = hl.dsp.exec_cmd

---@type Actions
local bespoke     = {
  volume_raise      = swayosd("--output-volume raise"),
  volume_lower      = swayosd("--output-volume lower"),
  volume_mute       = swayosd("--output-volume mute-toggle"),
  mic_mute          = swayosd("--input-volume mute-toggle"),
  brightness_inc    = swayosd("--brightness raise"),
  brightness_dec    = swayosd("--brightness lower"),
  lock              = raw("playerctl pause; hyprlock"),
  powermenu         = raw("walker -m menus:system"),
  open_notification = raw("swaync-client -t"),
  open_settings     = raw("gtk-launch nwg-displays"),
  next              = swayosd("--playerctl next"),
  prev              = swayosd("--playerctl previous"),
  play_pause        = swayosd("--playerctl play-pause"),
  launcher          = raw("walker"),
  bookmarks         = raw("walker -m bookmarks"),
  bluetooth         = raw("walker -m bluetooth"),
}

---@type table<string, Actions>
local backends    = { bespoke = bespoke }

backends.DMS      = {
  volume_raise      = dms("audio increment 3"),
  volume_lower      = dms("audio decrement 3"),
  volume_mute       = dms("audio mute"),
  mic_mute          = dms("audio micmute"),
  brightness_inc    = dms("brightness increment 5 ''"),
  brightness_dec    = dms("brightness decrement 5 ''"),
  lock              = dms("lock lock;playerctl pause"),
  powermenu         = dms("powermenu toggle"),
  open_notification = dms("notifications toggle"),
  open_settings     = dms("settings focusOrToggle"),
  next              = raw("playerctl next"),
  prev              = raw("playerctl previous"),
  play_pause        = raw("playerctl play-pause"),
  launcher          = raw("walker"),
  bookmarks         = raw("walker -m bookmarks"),
  bluetooth         = raw("walker -m bluetooth"),
}

backends.noctalia = {
  volume_raise      = noctalia("volume-up 3"),
  volume_lower      = noctalia("volume-down 3"),
  volume_mute       = noctalia("volume-mute"),
  mic_mute          = noctalia("mic-mute"),
  brightness_inc    = noctalia("brightness-up 5"),
  brightness_dec    = noctalia("brightness-down 5"),
  lock              = noctalia("session lock"),
  powermenu         = noctalia("panel-toggle session"),
  open_notification = noctalia("panel-toggle control-center notifications"),
  open_settings     = noctalia("settings-toggle"),
  next              = noctalia("media next"),
  prev              = noctalia("media previous"),
  play_pause        = noctalia("media toggle"),
  launcher          = noctalia("panel-toggle launcher"),
  bookmarks         = noctalia("panel-toggle launcher /bk"),
  bluetooth         = noctalia("panel-toggle control-center bluetooth"),
}

local BINARY      = { DMS = "dms", noctalia = "noctalia" }

---@return Actions
local function resolve()
  local cfg = UTIL.config.section("shell", { type = "bespoke" })
  local chosen = cfg.type

  local picked = backends[chosen]
  if picked == nil then
    UTIL.notif.osd(("Unknown shell %q, using bespoke"):format(tostring(chosen)))
    return bespoke
  end

  local binary = BINARY[chosen]
  if binary and not UTIL.helpers.cmdExists(binary) then
    UTIL.notif.osd(("Shell %q is configured but %q is not on PATH")
      :format(chosen, binary))
  end

  return picked
end

return resolve()
