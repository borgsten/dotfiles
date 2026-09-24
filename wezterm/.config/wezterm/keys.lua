local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
  config.keys = config.keys or {}

  local keys = {
    -- CTRL-l belongs to smart-splits (move right), so the plain ^L the shell
    -- expects goes out on the shifted key instead. CTRL-SHIFT-K still wipes
    -- the scrollback when you want that too.
    { key = 'L', mods = 'CTRL|SHIFT', action = act.SendKey { key = 'l', mods = 'CTRL' } },
    -- moved off CTRL-SHIFT-L, which wezterm binds to this by default
    { key = 'D', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },

    {
      key = '|',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = '\\',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = '_',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = '-',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end

  -- vim-style forward/back search in copy-mode: '/' and '?' open a
  -- search box, 'n'/'N' repeat the search forwards/backwards. Ctrl-r
  -- inside the search box cycles to case-sensitive/regex if needed --
  -- this wezterm build doesn't expose a true smart-case pattern type.
  if wezterm.gui then
    local search_action = act.Search { CaseInSensitiveString = '' }

    local copy_mode = wezterm.gui.default_key_tables().copy_mode
    table.insert(copy_mode, { key = '/', mods = 'NONE', action = search_action })
    -- '?' is bound as both NONE and SHIFT: wezterm's own defaults do the
    -- same for every shifted key, to work around an X11 SHIFT-normalization
    -- bug (https://github.com/wezterm/wezterm/issues/1906).
    table.insert(copy_mode, { key = '?', mods = 'NONE', action = search_action })
    table.insert(copy_mode, { key = '?', mods = 'SHIFT', action = search_action })
    table.insert(copy_mode, { key = 'n', mods = 'NONE', action = act.CopyMode 'NextMatch' })
    table.insert(copy_mode, { key = 'N', mods = 'NONE', action = act.CopyMode 'PriorMatch' })
    table.insert(copy_mode, { key = 'N', mods = 'SHIFT', action = act.CopyMode 'PriorMatch' })

    -- The default Enter binding in search_mode only jumps to a match
    -- (CopyMode 'PriorMatch') without leaving pattern-editing, so the
    -- copy_mode 'n'/'N' above never fire -- the keystroke just gets typed
    -- into the search box instead. 'AcceptPattern' is what actually hands
    -- control back to copy_mode's key table.
    local search_mode = wezterm.gui.default_key_tables().search_mode
    table.insert(search_mode, { key = 'Enter', mods = 'NONE', action = act.CopyMode 'AcceptPattern' })

    config.key_tables = config.key_tables or {}
    config.key_tables.copy_mode = copy_mode
    config.key_tables.search_mode = search_mode
  end
end

return M
