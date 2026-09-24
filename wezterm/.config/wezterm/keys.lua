local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
  config.keys = config.keys or {}

  local keys = {
    -- <C-l> is used in smart-splits, use <C-S-l> instead
    { key = 'L', mods = 'CTRL|SHIFT', action = act.SendKey({ key = 'l', mods = 'CTRL' }) },
    -- moved off CTRL-SHIFT-L, which wezterm binds to this by default
    { key = 'D', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
    -- default zoom bindings, swapped for the version that refreshes the tab bar
    { key = 'Z', mods = 'CTRL', action = require('tabbar').toggle_zoom },
    { key = 'Z', mods = 'CTRL|SHIFT', action = require('tabbar').toggle_zoom },
    { key = 'z', mods = 'CTRL|SHIFT', action = require('tabbar').toggle_zoom },

    {
      key = '|',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = '\\',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = '_',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = '-',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end

  -- Scroll 3 lines per tick instead of 1
  config.mouse_bindings = config.mouse_bindings or {}
  for button, lines in pairs({ WheelUp = -3, WheelDown = 3 }) do
    table.insert(config.mouse_bindings, {
      event = { Down = { streak = 1, button = { [button] = 1 } } },
      mods = 'NONE',
      mouse_reporting = false,
      alt_screen = false,
      action = act.ScrollByLine(lines),
    })
  end

  -- vim-style forward/back search in copy-mode: '/' and '?'
  if wezterm.gui then
    local search_action = act.Search({ CaseInSensitiveString = '' })

    local copy_mode = wezterm.gui.default_key_tables().copy_mode
    table.insert(copy_mode, { key = '/', mods = 'NONE', action = search_action })
    table.insert(copy_mode, { key = '?', mods = 'NONE', action = search_action })
    table.insert(copy_mode, { key = '?', mods = 'SHIFT', action = search_action })
    table.insert(copy_mode, { key = 'n', mods = 'NONE', action = act.CopyMode('NextMatch') })
    table.insert(copy_mode, { key = 'N', mods = 'NONE', action = act.CopyMode('PriorMatch') })
    table.insert(copy_mode, { key = 'N', mods = 'SHIFT', action = act.CopyMode('PriorMatch') })

    local search_mode = wezterm.gui.default_key_tables().search_mode
    table.insert(search_mode, { key = 'Enter', mods = 'NONE', action = act.CopyMode('AcceptPattern') })

    config.key_tables = config.key_tables or {}
    config.key_tables.copy_mode = copy_mode
    config.key_tables.search_mode = search_mode
  end
end

return M
