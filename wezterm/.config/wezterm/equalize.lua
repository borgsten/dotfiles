-- Resize the panes of a tab to equal widths. wezterm has no action for this,
-- and the Lua API can only resize through AdjustPaneSize, which moves the
-- nearest vertical divider above the *active* pane in the split tree --
-- whichever side of the pane it is on. So every divider is moved by activating
-- a pane next to it, checking that the right divider moved, and otherwise
-- undoing and trying the pane on its other side.
--
-- Limitation: a divider that is no pane's nearest one (the middle divider of
-- [[a | b] | [c | d]]) can't be reached that way and is left alone; only
-- dragging it with the mouse moves it.
local M = {}

-- Columns of the layout, left to right: the narrowest pane at each distinct
-- left edge, so a pane spanning several columns (e.g. a full-width bottom
-- pane) doesn't count as one of them.
local function columns(panes)
  local by_left = {}
  for _, p in ipairs(panes) do
    local c = by_left[p.left]
    if not c or p.width < c.width then
      by_left[p.left] = p
    end
  end
  local cols = {}
  for _, p in pairs(by_left) do
    cols[#cols + 1] = p
  end
  table.sort(cols, function(a, b)
    return a.left < b.left
  end)
  return cols
end

-- Target position of each of the n - 1 dividers: equal column widths, except
-- that dividers in `fixed` (index -> position) stay put and the columns on
-- either side of them are evened out separately.
local function targets(n, total, fixed)
  local t = {}
  local start, start_pos = 0, -1             -- a virtual divider just left of the tab
  for i = 1, n do
    local pos = i == n and total or fixed[i] -- i == n: the tab's right edge
    if pos then
      local k = i - start                    -- columns between the two fixed dividers
      local avail = pos - start_pos - 1 - (k - 1)
      local base, extra = math.floor(avail / k), avail % k
      local p = start_pos
      for j = start + 1, i - 1 do
        p = p + 1 + base + (j - start <= extra and 1 or 0)
        t[j] = p
      end
      t[i] = pos
      start, start_pos = i, pos
    end
  end
  return t
end

-- Plain function so it can be exercised outside wezterm. ops:
--   panes()                 { { id, left, width }, ... } for the tab
--   cols                    width of the tab in cells
--   activate(id)            make pane id the active one
--   adjust(direction, n)    AdjustPaneSize on the active pane
function M.run(ops)
  local function divider(i)
    local c = columns(ops.panes())[i]
    return c and c.left + c.width
  end

  local function shift(id, delta)
    ops.activate(id)
    ops.adjust(delta > 0 and 'Right' or 'Left', math.abs(delta))
  end

  -- Moving one divider can shift the ones nested inside the split it belongs
  -- to, and finding an unreachable one changes the targets, so repeat until
  -- nothing moves.
  local fixed = {}
  local n = #columns(ops.panes())
  for _ = 1, 2 * n + 3 do
    if n < 2 then
      return
    end
    local target = targets(n, ops.cols, fixed)
    local moved = false

    for i = 1, n - 1 do
      local delta = not fixed[i] and target[i] - divider(i) or 0
      if delta ~= 0 then
        local cols = columns(ops.panes())
        local reached = false
        for _, id in ipairs({ cols[i].id, cols[i + 1].id }) do
          shift(id, delta)
          if divider(i) == target[i] then
            reached = true
            break
          end
          -- moved a different divider: put it back
          shift(id, -delta)
        end
        moved = true
        if not reached then
          -- no pane moves this divider; keep it and redo the targets
          fixed[i] = divider(i)
          break
        end
      end
    end

    if not moved then
      return
    end
    n = #columns(ops.panes())
  end
end

function M.apply_to_config(config)
  local wezterm = require('wezterm')
  local act = wezterm.action

  local equalize = wezterm.action_callback(function(window, pane)
    local tab = pane:tab()
    if not tab then
      return
    end
    local original = tab:active_pane()

    local function panes()
      local out = {}
      for _, p in ipairs(tab:panes_with_info()) do
        if p.is_zoomed then
          return {} -- nothing to equalize while one pane fills the tab
        end
        out[#out + 1] = { id = p.pane:pane_id(), left = p.left, width = p.width }
      end
      return out
    end

    M.run({
      panes = panes,
      cols = tab:get_size().cols,
      activate = function(id)
        wezterm.mux.get_pane(id):activate()
      end,
      adjust = function(direction, amount)
        window:perform_action(act.AdjustPaneSize({ direction, amount }), tab:active_pane())
      end,
    })

    original:activate()
  end)

  config.keys = config.keys or {}
  table.insert(config.keys, { key = 'E', mods = 'CTRL|SHIFT', action = equalize })
end

return M
