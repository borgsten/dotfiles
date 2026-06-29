-- lib/monitor.lua
--
-- Applies monitor specs while avoiding the one thing that causes a visible
-- black flash: re-asserting the SAME monitor multiple times within a single
-- config evaluation (setup's external loop + clamshell's apply + hotplug
-- events can all fire in one reload cycle).
--
-- WHY NOT compare against live state?
-- It's tempting to skip hl.monitor() when hl.get_monitor() already reports the
-- desired values. That does NOT work across reloads: during config
-- re-evaluation the output has already been reset toward its default state
-- before this code runs, so the live read reflects a transient mid-reload
-- value, not "what the monitor will settle to if untouched". Skipping on a
-- match therefore lets the compositor's default win -- e.g. an internal panel
-- snapping back to scale 1.5 on every other reload. The correct baseline to
-- compare against (the post-reload default) is not observable here.
--
-- So the model is: apply each output exactly ONCE per evaluation, and only
-- suppress redundant repeats of that same output within the same evaluation.
-- The once-per-reload apply is REQUIRED, because the compositor re-defaults
-- the output every reload and something has to pin it back.

local M = {}

-- Set of outputs already applied during the current config evaluation.
-- Because the Lua state is rebuilt on every reload, this table starts empty
-- each reload -- exactly the lifetime we want (one evaluation = one dedupe set).
local applied = {}

--- Apply a monitor spec, unless this exact output was already applied during
--- the current config evaluation.
---@param spec HL.MonitorSpec
---@return boolean applied_now  true if hl.monitor() was actually called
function M.apply(spec)
  local key = spec.output
  if key and applied[key] then
    return false
  end
  hl.monitor(spec)
  if key then applied[key] = true end
  return true
end

--- Force-apply a spec even if the output was already applied this evaluation.
--- Use when a later decision must override an earlier apply of the same output
--- within one reload (e.g. clamshell disabling an internal that was enabled
--- earlier in the same pass).
---@param spec HL.MonitorSpec
function M.force(spec)
  hl.monitor(spec)
  if spec.output then applied[spec.output] = true end
end

return M
