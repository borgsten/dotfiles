local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

local opaque = false

local toggle_opacity = wezterm.action_callback(function(window)
  local config = window:get_config_overrides() or {}
  if opaque then
    config.window_background_opacity = 0.8
    config.text_background_opacity = 0.8
    opaque = false
  else
    config.window_background_opacity = 1.0
    config.text_background_opacity = 1.0
    opaque = true
  end
  window:set_config_overrides(config)
end)

function M.apply_to_config(config)
  config.keys = config.keys or {}

  local keys = {
    -- <C-l> is used in smart-splits, use <C-S-l> instead
    -- wezterm drops the viewport on clear instead of keeping it in scrollback,
    -- so scroll it up with newlines first. Newlines move the cursor to the bottom
    -- and then scroll exactly the rows in use.
    {
      key = 'L',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(function(window, pane)
        pane:inject_output(string.rep('\r\n', pane:get_dimensions().viewport_rows))
        window:perform_action(act.SendKey({ key = 'l', mods = 'CTRL' }), pane)
      end),
    },
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
    {
      key = 'O',
      mods = 'CTRL|SHIFT',
      action = toggle_opacity,
    },

    -- jump between prompts (needs OSC 133 marks, see POWERLEVEL9K_TERM_SHELL_INTEGRATION)
    { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
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

  -- Triple-click selects the whole semantic zone (a command's output, or its input line)
  table.insert(config.mouse_bindings, {
    event = { Down = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor('SemanticZone'),
  })

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
