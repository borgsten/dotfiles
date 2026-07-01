local M = {}

local dbg = require("lib.debug")
local util = require("lib.util")

---@type table<string, HL.MonitorSpec>
local applied = {}

--- Compare monitor specs for equality
---@param a HL.MonitorSpec
---@param b HL.MonitorSpec
---@return boolean
local function monitorSpecEqual(a, b)
  local monitor_spec_keys = {
    "bitdepth", "cm", "disabled", "icc", "max_avg_luminance", "max_luminance",
    "min_luminance", "mirror", "mode", "output", "position", "reserved",
    "reserved_area", "scale", "sdr_eotf", "sdr_max_luminance", "sdr_min_luminance",
    "sdrbrightness", "sdrsaturation", "supports_hdr", "supports_wide_color",
    "transform", "vrr"
  }
  return util.userdataEqual(monitor_spec_keys, a, b)
end


--- Apply a monitor spec, unless this exact spec was already applied during
--- the current config evaluation.
---@param spec HL.MonitorSpec
---@return boolean applied_now  true if hl.monitor() was actually called
function M.apply(spec)
  local key = spec.output

  if key and monitorSpecEqual(spec, applied[key]) then
    dbg.debug(string.format("monitor.apply: skipping %s (already applied)", key))
    return false
  end
  dbg.trace(string.format("monitor.apply: applying %s", key or "<no output>"))
  hl.monitor(spec)
  if key then applied[key] = spec end
  dbg.trace("Post state:", applied)
  return true
end

--- Force-apply a spec even if the spec was already applied this evaluation.
---@param spec HL.MonitorSpec
function M.force(spec)
  dbg.trace(string.format("monitor.force: applying %s", spec.output or "<no output>"))
  hl.monitor(spec)
  if spec.output then applied[spec.output] = spec end
end

return M
