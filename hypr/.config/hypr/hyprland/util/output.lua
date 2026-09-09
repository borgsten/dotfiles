--- Applying monitor specs. Named `output` to stay distinct from the
--- `hyprland/monitors.lua` policy module.
---@class Util.Output
local M = {}

local dbg = UTIL.dbg

--- TRAP: `hl.monitor()` registers a monitor *rule*, not a one-shot modeset.
--- A reload clears every rule, so every evaluation must re-declare all of
--- them; skip one because the output already looks right and Hyprland
--- auto-arranges the displays instead.
---
--- Hence per-evaluation by design. It only suppresses repeat applies within
--- one evaluation -- clamshell calls apply() three times in quick succession.
---@type table<string, HL.MonitorSpec>
local applied = {}

---@param spec HL.MonitorSpec
---@return boolean applied_now
function M.apply(spec)
  local key = spec.output

  if key and UTIL.tbl.deepEqual(spec, applied[key]) then
    dbg.debug(("output.apply: skipping %s (applied this evaluation)"):format(key))
    return false
  end

  dbg.trace(("output.apply: applying %s"):format(key or "<no output>"))
  hl.monitor(spec)
  if key then applied[key] = spec end
  return true
end

--- Apply even if the memo says it was already done this evaluation.
---@param spec HL.MonitorSpec
function M.force(spec)
  dbg.trace(("output.force: applying %s"):format(spec.output or "<no output>"))
  hl.monitor(spec)
  if spec.output then applied[spec.output] = spec end
end

---@param spec HL.MonitorSpec
---@param overrides table
---@return HL.MonitorSpec
function M.override(spec, overrides)
  local out = {}
  for k, v in pairs(spec) do out[k] = v end
  for k, v in pairs(overrides) do out[k] = v end
  return out
end

---@param name string?
---@return HL.Monitor[]
function M.othersThan(name)
  local others = {}
  for _, m in ipairs(hl.get_monitors()) do
    if m.name ~= name then others[#others + 1] = m end
  end
  return others
end

return M
