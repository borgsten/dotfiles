--------------------------------------------------------------------------------
---                               SCRATCHPAD                                 ---
--------------------------------------------------------------------------------

M = {}

SCRATCHPAD_WORKSPACE_NAME = "special:scratch"
SCRATCHPAD_CLASS_NAME = "com.scratch"

local dbg = require("lib.debug")

--- Get scratchpad window if it exists
---@return HL.Window | nil
local function getScratchWindow()
  local windows = hl.get_windows({ class = SCRATCHPAD_CLASS_NAME })
  for _, window in ipairs(windows) do
    dbg.debug("window: " .. window.title .. " class: " .. window.initial_class .. " workspace " .. window.workspace.name)
    if window.initial_class == SCRATCHPAD_CLASS_NAME then
      return window
    end
  end
  return nil
end

--- Check if scratchpad window is stashed in special workspace
---@param window HL.Window
---@return boolean
local function isWindowStashed(window)
  dbg.debug(string.format("Window %s is in workspace %s", window.title, window.workspace.name))
  if window.workspace.name == SCRATCHPAD_WORKSPACE_NAME then
    dbg.debug("scratchpad window is stashed")
    return true
  end

  return false
end

--- Check if window is on active workspace
---@param window HL.Window
---@return boolean
local function isWindowOnActiveWorkspace(window)
  local active_workspace = hl.get_active_workspace()
  local in_active = window.workspace == active_workspace
  dbg.debug(string.format("Is %son the active workspace", in_active and "" or "not "))
  return in_active
end

--- Move window to scratchpad stash
---@param window HL.Window
local function stashWindow(window)
  dbg.debug(string.format("moving window %s(%d) to workspace %s", window.title, window.stable_id,
    SCRATCHPAD_WORKSPACE_NAME))
  hl.dispatch(hl.dsp.window.move({ workspace = SCRATCHPAD_WORKSPACE_NAME, follow = false, window = window }))
end

--- Retrieve window from scratchpad stash to active workspace
---@param window HL.Window
local function unstashWindow(window)
  local activeWorkspace = hl.get_active_workspace()
  if activeWorkspace == nil then
    dbg.error("no active workspace found")
    return
  end
  dbg.debug(string.format("moving window %s(%d) to workspace %s", window.title, window.stable_id, activeWorkspace.name))
  hl.dispatch(hl.dsp.window.move({ workspace = activeWorkspace.name, follow = true, window = window }))
end

--- Toggle terminal scratchpad window
function M.toggleScratchpad()
  local scratch = getScratchWindow()
  if scratch == nil then
    dbg.warn("no scratchpad window found, launching")
    return
  end

  if isWindowStashed(scratch) or not isWindowOnActiveWorkspace(scratch) then
    dbg.debug("scratchpad is stashed, unstashing")
    unstashWindow(scratch)
  else
    stashWindow(scratch)
    dbg.debug("scratchpad is not stashed, stashing")
  end
end

--- Move all windows in scratchpad workspace that are not scratchpad windows to active workspace
function M.emptyScratchpad()
  local scratchpad_windows = hl.get_workspace_windows(SCRATCHPAD_WORKSPACE_NAME)
  for _, window in ipairs(scratchpad_windows) do
    if window.initial_class ~= SCRATCHPAD_CLASS_NAME then
      dbg.warn(string.format(
        "window %s(%d) is in scratchpad workspace but is not a scratchpad window, moving to active workspace",
        window.title, window.stable_id))
      unstashWindow(window)
    end
  end
end

--- Setup scratchpad related settings
function M.setup()
  hl.window_rule({
    name      = "scratchpad",
    match     = { class = "com.scratch" },
    float     = true,
    workspace = "special:scratch silent",
    size      = "80% 80%",
  })

  hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- scratch")
  end)
end

return M
