--- Applying monitor specs. Named `output` to stay distinct from the
--- `land/monitors.lua` policy module.
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

--- Keys `Config.MonitorSpec` adds for our own modules. Hyprland never sees them.
local OWN_KEYS = { sharing = true }

---@param spec Config.MonitorSpec
---@return HL.MonitorSpec
local function toHyprland(spec)
    local out = {}
    for k, v in pairs(spec) do
        if not OWN_KEYS[k] then
            out[k] = v
        end
    end
    return out
end

---@param spec Config.MonitorSpec
---@return boolean applied_now
function M.apply(spec)
    local key = spec.output

    if key and UTIL.tbl.deepEqual(spec, applied[key]) then
        dbg.debug(('output.apply: skipping %s (applied this evaluation)'):format(key))
        return false
    end

    dbg.trace(('output.apply: applying %s'):format(key or '<no output>'))
    hl.monitor(toHyprland(spec))
    if key then
        applied[key] = spec
    end
    return true
end

--- Apply even if the memo says it was already done this evaluation.
---@param spec Config.MonitorSpec
function M.force(spec)
    dbg.trace(('output.force: applying %s'):format(spec.output or '<no output>'))
    hl.monitor(toHyprland(spec))
    if spec.output then
        applied[spec.output] = spec
    end
end

---@param spec Config.MonitorSpec
---@param overrides table
---@return Config.MonitorSpec
function M.override(spec, overrides)
    local out = {}
    for k, v in pairs(spec) do
        out[k] = v
    end
    for k, v in pairs(overrides) do
        out[k] = v
    end
    return out
end

---@param name string?
---@return HL.Monitor[]
function M.othersThan(name)
    local others = {}
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= name then
            others[#others + 1] = m
        end
    end
    return others
end

--- Whether `spec` describes `mon`, by connector name or by a `desc:` prefix
--- of the EDID description -- the same two forms Hyprland accepts.
---@param spec Config.MonitorSpec
---@param mon HL.Monitor
---@return boolean
function M.matches(spec, mon)
    local desc = spec.output:match('^desc:(.*)$')
    if desc then
        return mon.description:sub(1, #desc) == desc
    end
    return spec.output == mon.name
end

return M
