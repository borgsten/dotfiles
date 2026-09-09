--------------------------------------------------------------------------------
---                                  GROUPS                                  ---
--------------------------------------------------------------------------------
--- Hyprland exposes both halves of i3's `move <dir>` -- `into_group` (a silent
--- no-op when there is no group that way) and `direction` (never enters one)
--- -- but not the `movewindoworgroup` that picks between them. This composes it.
---
--- `into_or_create_group` is deliberately unused: it *always* groups, so a
--- directional move would turn every window move into a new tab stack.

local M = {}

local dbg = UTIL.dbg

--- Snapshot what changes when a window enters or leaves a group, so a no-op
--- `into_group` can be told apart from a real move.
---@param win HL.Window|nil
---@return string
local function fingerprint(win)
  if win == nil then return "" end
  local size = win.group ~= nil and win.group.size or 0
  return string.format("%d:%d:%d", win.at.x, win.at.y, size)
end

--- i3-style directional move: push the active window into the group beside
--- it if there is one, otherwise move it through the tiling tree as usual.
---@param dir "left"|"right"|"up"|"down"
---@return function
function M.MoveOrGroup(dir)
  return function()
    local before = fingerprint(hl.get_active_window())

    hl.dispatch(hl.dsp.window.move({ into_group = dir }))

    if fingerprint(hl.get_active_window()) == before then
      dbg.debug("no group " .. dir .. " of the active window, moving instead")
      hl.dispatch(hl.dsp.window.move({ direction = dir }))
    end
  end
end

--- Gather every tiled window on the active workspace into one group, ordered
--- left to right. Uses `group:add` rather than a directional `moveintogroup`:
--- the dwindle tree gives no guarantee the group is ever "to the left" of the
--- next window -- in a 2x2 split half of them sit below it.
function M.SwallowWorkspace()
  local ws = hl.get_active_workspace()
  if ws == nil then
    dbg.error("swallow: no active workspace")
    return
  end

  local tiled = {}
  for i, w in ipairs(hl.get_workspace_windows(ws.name)) do
    if not w.floating then
      tiled[#tiled + 1] = { win = w, x = w.at.x, y = w.at.y, seq = i }
    end
  end

  if #tiled < 2 then
    dbg.debug("swallow: fewer than two tiled windows, nothing to group")
    return
  end

  -- `seq` breaks ties: existing group tabs all report the group's geometry.
  table.sort(tiled, function(a, b)
    if a.x ~= b.x then return a.x < b.x end
    if a.y ~= b.y then return a.y < b.y end
    return a.seq < b.seq
  end)

  local head = tiled[1].win
  hl.dispatch(hl.dsp.focus({ window = head }))
  if head.group == nil then
    hl.dispatch(hl.dsp.group.toggle())
  end

  local group = (hl.get_active_window() or head).group
  if group == nil then
    dbg.error("swallow: could not create a group on the leftmost window")
    return
  end

  for i = 2, #tiled do
    local w = tiled[i].win
    if w.group == nil then
      group:add(w)
    end
  end

  hl.dispatch(hl.dsp.focus({ window = head }))
end

return M
