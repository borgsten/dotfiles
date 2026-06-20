---@class Actions
---@field volume_raise function
---@field volume_lower function
---@field volume_mute function
---@field mic_mute function
---@field brightness_inc function
---@field brightness_dec function
---@field lock function
---@field powermenu function
---@field open_notification function
---@field open_settings function
---@field next function
---@field prev function
---@field play_pause function

--- Create dms dispatcher
---@param cmd string
---@param prefix string?
---@return HL.Dispatcher
local function build_dms(cmd, prefix)
  cmd = "dms ipc call " .. cmd
  if prefix ~= nil then
    cmd = prefix .. ";" .. cmd
  end
  return hl.dsp.exec_cmd(cmd)
end

--- Create noctalia dispatcher
---@param cmd string
---@param prefix string?
---@return HL.Dispatcher
local function build_noctalia(cmd, prefix)
  cmd = "noctalia msg " .. cmd
  if prefix ~= nil then
    cmd = prefix .. ";" .. cmd
  end
  return hl.dsp.exec_cmd(cmd)
end

--- Create swayosd-client command dispatcher
---@param cmd string
---@return fun()
local function build_swayosd(cmd)
  return function()
    local swayosd = "swayosd-client --monitor"
    local monitor = hl.get_active_monitor().name
    local cmd_ = table.concat({ swayosd, monitor, cmd }, " ")
    hl.dispatch(hl.dsp.exec_cmd(cmd_))
  end
end

--- Create "raw" command dispatcher
---@param cmd string
---@return HL.Dispatcher
local function build_raw(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local actions = {
  dms = {
    volume_raise = build_dms("audio increment 3"),
    volume_lower = build_dms("audio decrement 3"),
    volume_mute = build_dms("audio mute"),
    mic_mute = build_dms("audio micmute"),
    brightness_inc = build_dms("brightness increment 5 ''"),
    brightness_dec = build_dms("brightness decrement 5 ''"),
    lock = build_dms("lock lock;playerctl pause"),
    powermenu = build_dms("powermenu toggle"),
    open_notification = build_dms("notifications toggle"),
    open_settings = build_dms("settings focusOrToggle"),
    next = build_raw("playerctl next"),
    prev = build_raw("playerctl previous"),
    play_pause = build_raw("playerctl play-pause"),
  },
  noctalia = {
    volume_raise = build_noctalia("volume-up 3"),
    volume_lower = build_noctalia("volume-down 3"),
    volume_mute = build_noctalia("volume-mute"),
    mic_mute = build_noctalia("mic-mute"),
    brightness_inc = build_noctalia("brightness-up 5"),
    brightness_dec = build_noctalia("brightness-down 5"),
    lock = build_noctalia("session lock"),
    powermenu = build_noctalia("panel-toggle session"),
    open_notification = build_noctalia("panel-toggle control-center notifications"),
    open_settings = build_noctalia("settings-toggle"),
    next = build_noctalia("media next"),
    prev = build_noctalia("media previous"),
    play_pause = build_noctalia("media toggle"),
  },
  external = {
    volume_raise = build_swayosd("--output-volume raise"),
    volume_lower = build_swayosd("--output-volume lower"),
    volume_mute = build_swayosd("--output-volume mute-toggle"),
    mic_mute = build_swayosd("--input-volume mute-toggle"),
    brightness_inc = build_swayosd("--brightness raise"),
    brightness_dec = build_swayosd("--brightness lower"),
    lock = build_raw("playerctl pause; hyprlock"),
    powermenu = build_raw("walker -m menus:system"),
    open_notification = build_raw("swaync-client -t"),
    open_settings = build_raw("gtk-launch nwg-displays"),
    next = build_swayosd("--playerctl next"),
    prev = build_swayosd("--playerctl previous"),
    play_pause = build_swayosd("--playerctl play-pause"),
  },
}

--- Get shell actions for current session
---@return Actions
local function get_shell_actions()
  local util = require("lib.util")

  if util.service_active("dms", true) then
    return actions.dms
  elseif util.service_active("noctalia", true) then
    return actions.noctalia
  end
  return actions.external
end

return get_shell_actions()
