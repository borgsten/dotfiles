local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

-- tmux's default prefix. Meant as training wheels for tmux muscle memory;
local PREFIX = { key = 'b', mods = 'CTRL' }
local TABLE = 'tmux'

local PASSTHROUGH = { tmux = true, ssh = true, mosh = true }

-- Pass the prefix through when tmux runs locally or in a ssh session.
local function pass_through(pane)
  if pane:get_domain_name() ~= 'local' then
    return true
  end
  local name = (pane:get_foreground_process_name() or ''):match('([^/\\]+)$')
  return PASSTHROUGH[name] == true
end

local rename_tab = act.PromptInputLine {
  description = 'Rename tab',
  action = wezterm.action_callback(function(window, _, line)
    if line then
      window:active_tab():set_title(line)
    end
  end),
}

local break_pane = wezterm.action_callback(function(_, pane)
  pane:move_to_new_tab()
end)

function M.apply_to_config(config)
  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}

  table.insert(config.keys, {
    key = PREFIX.key,
    mods = PREFIX.mods,
    action = wezterm.action_callback(function(window, pane)
      if pass_through(pane) then
        window:perform_action(act.SendKey(PREFIX), pane)
      else
        -- no until_unknown: it pops on *any* unmatched key-down, including a
        -- bare Shift/AltGr press, so shifted keys like '"' and '%' never land.
        -- one_shot alone ignores modifier presses.
        window:perform_action(act.ActivateKeyTable { name = TABLE, one_shot = true }, pane)
      end
    end),
  })

  local bindings = {
    { key = 'c',          action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'n',          action = act.ActivateTabRelative(1) },
    { key = 'p',          action = act.ActivateTabRelative(-1) },
    { key = 'l',          action = act.ActivateLastTab },
    { key = 'w',          action = act.ShowTabNavigator },
    { key = ',',          action = rename_tab },
    { key = '&',          action = act.CloseCurrentTab { confirm = true } },

    { key = '%',          action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '"',          action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'x',          action = act.CloseCurrentPane { confirm = true } },
    { key = 'z',          action = require('tabbar').toggle_zoom },
    { key = 'o',          action = act.ActivatePaneDirection 'Next' },
    { key = 'q',          action = act.PaneSelect },
    { key = '!',          action = break_pane },
    { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },

    { key = '[',          action = act.ActivateCopyMode },
    { key = ']',          action = act.PasteFrom 'Clipboard' },
    { key = ':',          action = act.ActivateCommandPalette },
    { key = 'r',          action = act.ReloadConfiguration },

    { key = 'Escape',     action = act.PopKeyTable },

    -- prefix twice sends a literal C-b
    {
      key = PREFIX.key,
      mods = PREFIX.mods,
      action = act.SendKey(PREFIX)
    },
  }

  -- tab numbers match the tab bar: 1..9, then 0 for the tenth
  for i = 1, 9 do
    table.insert(bindings, { key = tostring(i), action = act.ActivateTab(i - 1) })
  end
  table.insert(bindings, { key = '0', action = act.ActivateTab(9) })

  local key_table = {}
  for _, b in ipairs(bindings) do
    table.insert(key_table, { key = b.key, mods = b.mods or 'NONE', action = b.action })
    -- shifted symbols are bound as both NONE and SHIFT, same as wezterm's own
    -- defaults (https://github.com/wezterm/wezterm/issues/1906)
    if not b.mods and b.key:match('^%p$') then
      table.insert(key_table, { key = b.key, mods = 'SHIFT', action = b.action })
    end
  end
  config.key_tables[TABLE] = key_table
end

return M
