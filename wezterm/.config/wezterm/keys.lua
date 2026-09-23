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
end

return M
