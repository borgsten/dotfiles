--------------------------------------------------------------------------------
---                                  GROUPS                                  ---
--------------------------------------------------------------------------------
--- A Hyprland group is i3's tabbed container. `hl.dsp.window.move` exposes
--- both halves of i3's `move <dir>` separately -- `into_group` (push the
--- window into the container next to it, a silent no-op when there is no
--- group that way) and `direction` (move through the tiling tree, never
--- entering a group) -- but not the `movewindoworgroup` dispatcher that
--- picks between them. This module composes that behaviour.
---
--- Note `into_or_create_group` is deliberately not used: it *always* groups,
--- so binding it to a directional move would turn every window move into a
--- new tab stack.

local M = {}

local dbg = require("lib.debug")

--- Snapshot the parts of a window that change when it enters or leaves a
--- group, so a no-op `into_group` can be told apart from a real move.
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

return M
