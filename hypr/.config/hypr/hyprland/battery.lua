--------------------------------------------------------------------------------
---                               KEYBINDINGS                                ---
--------------------------------------------------------------------------------

local notified_low = false
local notified_critical = false
local LOW_LEVEL = 20
local CRIT_LEVEL = 10

local function find_battery_path()
  for _, name in ipairs({ "BAT0", "BAT1", "BATT", "BAT" }) do
    local f = io.open("/sys/class/power_supply/" .. name .. "/capacity", "r")
    if f then f:close(); return "/sys/class/power_supply/" .. name end
  end
  return nil
end

local BATTERY_PATH = find_battery_path()

--- Get current battery status
---@return string? status
local function getStatus()
  if not BATTERY_PATH then return nil end
  local f = io.open(BATTERY_PATH .. "/status", "r")
  if not f then return nil end
  local status = f:read("*all"):gsub("%s+", "")
  f:close()
  return status
end

local function check_battery()
  local status = getStatus()
  if status == "Charging" then
    notified_low = false
    notified_critical = false
    return
  end

  local file = io.open(BATTERY_PATH .. "/capacity", "r")
  if not file then
    return
  end

  local level = tonumber(file:read("*all"))
  file:close()

  local notif = require("lib.notif")
  local function notify(title, message)
    notif.Send(title, message,
      { icon = "dialog-warning", transient = true, timeout = 15 * 60 * 1000, criticality = "critical" })
  end

  if level <= CRIT_LEVEL and not notified_critical then
    notify("Critical battery", "Battery level " .. level .. "%")

    notified_critical = true
    notified_low = true
  elseif level <= LOW_LEVEL and not notified_low and level > CRIT_LEVEL then
    notify("Low battery", "Battery level " .. level .. "%")

    notified_low = true
  end
end

if getStatus() ~= nil then
  hl.timer(check_battery, { timeout = 30000, type = "repeat" })
end
