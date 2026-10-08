--------------------------------------------------------------------------------
---                                PRESENTING                                ---
--------------------------------------------------------------------------------
--- Do Not Disturb while the screen may be seen by others: during a screen
--- share through the compositor, or while a display that captures is attached.
---
--- An HDMI capture device (a meeting room hub) is just a monitor to Hyprland,
--- so it can only be recognised by its identity: specs in `monitors` marked
--- `sharing = true`, plus, by default, any display `monitors` does not know.

---@class Config.Presenting
---@field enabled boolean
---@field unknown_monitors boolean  treat displays missing from `monitors` as capturing

local M = {}

local dbg = UTIL.dbg

---@type Config.Presenting
local DEFAULTS = { enabled = true, unknown_monitors = true }

--- Built-in panels never capture, whether or not `monitors.internal` is set.
local INTERNAL_PREFIXES = { 'eDP-', 'LVDS-', 'DSI-' }

---@param name string
---@return boolean
local function isInternalPanel(name)
    for _, prefix in ipairs(INTERNAL_PREFIXES) do
        if name:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

---@return Config.MonitorSpec[]
local function knownSpecs()
    local monitors = require('land.monitors').config()
    local specs = {}
    for i, spec in ipairs(monitors.external) do
        specs[i] = spec
    end
    if monitors.internal then
        specs[#specs + 1] = monitors.internal
    end
    return specs
end

---@param action ShellAction
local function run(action)
    if type(action) == 'function' then
        action()
    else
        hl.dispatch(action)
    end
end

function M.setup()
    local cfg = UTIL.config.section('presenting', DEFAULTS)
    if not cfg.enabled then
        return
    end

    local shell = require('land.shell')
    local specs = knownSpecs()

    ---@param mon HL.Monitor
    ---@return boolean
    local function captures(mon)
        if isInternalPanel(mon.name) then
            return false
        end
        -- First match wins, so a `desc:` spec can single out one display on a
        -- connector that another spec also names.
        for _, spec in ipairs(specs) do
            if UTIL.output.matches(spec, mon) then
                return spec.sharing == true
            end
        end
        return cfg.unknown_monitors
    end

    ---@param gone string?  name of a monitor being removed, possibly still listed
    ---@return boolean
    local function capturingMonitor(gone)
        for _, mon in ipairs(hl.get_monitors()) do
            if mon.name ~= gone and captures(mon) then
                dbg.trace(('presenting: %s (%s) captures'):format(mon.name, mon.description))
                return true
            end
        end
        return false
    end

    -- Both live in this Lua state, which a reload rebuilds: a share running
    -- across a reload is forgotten, and its end then leaves DND on.
    local shares = 0
    local active = false

    --- Only acts on transitions, so toggling DND by hand mid-share sticks, and
    --- a reload with nothing to hide does not clear a DND set by hand.
    ---@param gone string?
    local function apply(gone)
        local want = shares > 0 or capturingMonitor(gone)
        if want == active then
            return
        end
        active = want
        dbg.trace(('presenting: DND %s (shares=%d)'):format(want and 'on' or 'off', shares))
        run(want and shell.dnd_on or shell.dnd_off)
    end

    hl.on('screenshare.state', function(is_active, kind, name)
        dbg.trace(('presenting: screenshare %s type=%s name=%s'):format(tostring(is_active), tostring(kind), tostring(name)))
        shares = is_active and shares + 1 or math.max(shares - 1, 0)
        apply()
    end)

    hl.on('monitor.added', function()
        apply()
    end)

    ---@param mon HL.Monitor
    hl.on('monitor.removed', function(mon)
        apply(mon and mon.name)
    end)

    apply()
end

return M
