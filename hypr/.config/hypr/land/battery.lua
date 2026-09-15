--------------------------------------------------------------------------------
---                                 BATTERY                                  ---
--------------------------------------------------------------------------------
--- Latching lives in `util/watch.lua`; this is where to read and what to say.

---@class Config.Battery
---@field low integer      warn at or below this percentage
---@field critical integer warn more loudly at or below this percentage
---@field poll_ms integer

local M = {}

---@type Config.Battery
local DEFAULTS = { low = 20, critical = 10, poll_ms = 30000 }

---@return string?
local function findBatteryPath()
  local candidates = {}
  for i, n in ipairs({ "BAT0", "BAT1", "BATT", "BAT" }) do
    candidates[i] = "/sys/class/power_supply/" .. n .. "/capacity"
  end
  local found = UTIL.sys.firstExisting(candidates)
  if found == nil then return nil end
  return (found:gsub("/capacity$", ""))
end

local TITLES = { critical = "Critical battery", low = "Low battery" }

function M.setup()
  local path = findBatteryPath()
  if path == nil then return end -- no battery

  local cfg = UTIL.config.section("battery", DEFAULTS)

  UTIL.watch.thresholds({
    poll_ms = cfg.poll_ms,
    levels = {
      { at = cfg.critical, tag = "critical" },
      { at = cfg.low,      tag = "low" },
    },

    read = function()
      return UTIL.sys.readNumber(path .. "/capacity"), UTIL.sys.readFile(path .. "/status")
    end,

    clear_when = function(_, status)
      return status == "Charging"
    end,

    on_enter = function(tag, level)
      UTIL.notif.send(TITLES[tag], ("Battery level %d%%"):format(math.floor(level)), {
        icon        = "dialog-warning",
        transient   = true,
        timeout     = 15 * 60 * 1000,
        criticality = "critical",
      })
    end,
  })
end

return M
