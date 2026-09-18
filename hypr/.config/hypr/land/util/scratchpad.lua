--- A floating window parked on a special workspace. Hyprland's own toggle
--- shows the workspace; this moves the *window*, so it arrives on whichever
--- workspace you summoned it from.
---@class Util.Scratchpad
local M = {}

---@class Util.Scratchpad.Spec
---@field name string        identifier, and the special workspace's suffix
---@field class string       regex matched against the window's class
---@field cmd? string        command that spawns it; omit to never auto-launch,
---                          only adopt a window you started yourself
---@field size? number       fraction of the monitor, 0.0-1.0 (default 0.8)
---@field workspace? string  defaults to `"special:" .. name`

---@class Util.Scratchpad.Instance
---@field toggle fun()  summon to the active workspace, or stash away
---@field empty fun()   evict foreign windows from the stash
---@field setup fun()   register the window rule and autostart

--- Create a scratchpad from a spec.
---@param spec Util.Scratchpad.Spec
---@return Util.Scratchpad.Instance
function M.new(spec)
  local dbg = UTIL.dbg
  local name = assert(spec.name, "scratchpad: 'name' is required")
  local class = assert(spec.class, "scratchpad: 'class' is required")
  local cmd = spec.cmd
  local workspace = spec.workspace or ("special:" .. name)
  local size = spec.size or 0.8
  local tag = "scratch-" .. name

  local S = {}

  ---@param w HL.Window
  ---@return boolean
  local function hasTag(w)
    local tags = w.tags
    if type(tags) == "table" then
      for _, t in ipairs(tags) do
        if t == tag or t == tag .. "*" then return true end
      end
      return false
    end
    return tags == tag or tags == tag .. "*"
  end

  ---@return HL.Window|nil
  local function findWindow()
    for _, w in ipairs(hl.get_windows({})) do
      if hasTag(w) then return w end
    end
    return nil
  end

  ---@param w HL.Window
  local function isStashed(w)
    return w.workspace.name == workspace
  end

  --- By name, not userdata identity: identity would depend on Hyprland
  --- handing back the same object.
  ---@param w HL.Window
  local function isOnActiveWorkspace(w)
    local active = hl.get_active_workspace()
    return active ~= nil and w.workspace.name == active.name
  end

  ---@param w HL.Window
  local function stash(w)
    dbg.debug(("scratchpad %s: stashing %s(%d)"):format(name, w.title, w.stable_id))
    hl.dispatch(hl.dsp.window.move({ workspace = workspace, follow = false, window = w }))
  end

  ---@param w HL.Window
  local function unstash(w)
    local active = hl.get_active_workspace()
    if active == nil then
      dbg.error(("scratchpad %s: no active workspace"):format(name))
      return
    end
    dbg.debug(("scratchpad %s: summoning %s(%d) to %s")
      :format(name, w.title, w.stable_id, active.name))
    hl.dispatch(hl.dsp.window.move({ workspace = active.name, follow = true, window = w }))
  end

  function S.toggle()
    local w = findWindow()
    if w == nil then
      if cmd == nil then
        dbg.info(("scratchpad %s: no window and no cmd configured, nothing to do"):format(name))
        return
      end
      dbg.warn(("scratchpad %s: no window, launching %q"):format(name, cmd))
      hl.exec_cmd(cmd)
      return
    end

    if isStashed(w) or not isOnActiveWorkspace(w) then
      unstash(w)
      hl.dispatch(hl.dsp.window.bring_to_top({ window = w }))
      hl.dispatch(hl.dsp.focus({ window = w }))
    else
      stash(w)
    end
  end

  --- Rescue any non-scratchpad window from the stash workspace.
  function S.empty()
    for _, w in ipairs(hl.get_workspace_windows(workspace)) do
      if not hasTag(w) then
        dbg.warn(("scratchpad %s: evicting stray window %s(%d)")
          :format(name, w.title, w.stable_id))
        unstash(w)
      end
    end
  end

  function S.setup()
    hl.window_rule({
      name  = "scratchpad-tag-" .. name,
      match = { class = class },
      tag   = "+" .. tag,
    })

    hl.window_rule({
      name      = "scratchpad-" .. name,
      match     = { tag = tag },
      center    = true,
      float     = true,
      size      = { ("monitor_w * %s"):format(size), ("monitor_h * %s"):format(size) },
      workspace = workspace .. " silent",
    })

    if cmd ~= nil then
      hl.on("hyprland.start", function()
        hl.exec_cmd(cmd)
      end)
    end
  end

  return S
end

return M
