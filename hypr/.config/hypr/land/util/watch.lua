--- Latching threshold watcher.
---@class Util.Watch
local M = {}

---@class Util.Watch.Level
---@field at number   fires when the value is at or below this
---@field tag string  identifier handed back to `on_enter`

---@class Util.Watch.Spec
---@field read fun(): number?, any        value (nil skips the tick), plus opaque state
---@field poll_ms integer
---@field levels Util.Watch.Level[]
---@field on_enter fun(tag: string, value: number, state: any)
---@field clear_when? fun(value: number, state: any): boolean

--- Poll a falling value, firing `on_enter` once per threshold crossing and
--- re-arming when it recovers.
---@param spec Util.Watch.Spec
---@return HL.Timer
function M.thresholds(spec)
  local levels = {}
  for i, lv in ipairs(spec.levels) do levels[i] = lv end
  -- Ascending, so the most severe level is considered first.
  table.sort(levels, function(a, b) return a.at < b.at end)

  local latched = {}

  local function tick()
    local value, state = spec.read()
    if value == nil then return end

    for _, lv in ipairs(levels) do
      if value > lv.at then latched[lv.tag] = nil end
    end

    if spec.clear_when and spec.clear_when(value, state) then
      for _, lv in ipairs(levels) do latched[lv.tag] = nil end
      return
    end

    for _, lv in ipairs(levels) do
      if value <= lv.at then
        if not latched[lv.tag] then
          -- Latch the less severe levels too, so falling 25 -> 5 reports
          -- critical without also reporting low on the way past.
          for _, other in ipairs(levels) do
            if other.at >= lv.at then latched[other.tag] = true end
          end
          spec.on_enter(lv.tag, value, state)
        end
        return
      end
    end
  end

  return hl.timer(tick, { timeout = spec.poll_ms, type = "repeat" })
end

return M
