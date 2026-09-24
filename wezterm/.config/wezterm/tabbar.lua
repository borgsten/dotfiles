local wezterm = require('wezterm')

local M = {}

local function basename(s)
  return (s:gsub('(.*[/\\])(.*)', '%2'))
end

local function status_color(window)
  local palette = window:effective_config().resolved_palette or {}
  local tab_bar = palette.tab_bar or {}
  local inactive = tab_bar.inactive_tab or {}
  return inactive.fg_color or palette.foreground or '#808080'
end

local function is_zoomed(tab)
  for _, p in ipairs(tab and tab:panes_with_info() or {}) do
    if p.is_zoomed then
      return true
    end
  end
  return false
end

-- Force the tab bar on while a pane is zoomed so the Z flag is visible even
-- with a single tab.
local function show_tab_bar_when_zoomed(window, zoomed)
  if zoomed == nil then
    zoomed = is_zoomed(window:active_tab())
  end

  local want = nil -- nil falls back to config.hide_tab_bar_if_only_one_tab
  if zoomed then
    want = false
  end

  local overrides = window:get_config_overrides() or {}
  if overrides.hide_tab_bar_if_only_one_tab ~= want then
    overrides.hide_tab_bar_if_only_one_tab = want
    window:set_config_overrides(overrides)
  end
end

-- Drop-in for TogglePaneZoomState that updates the tab bar right away instead
-- of waiting for the next update-status tick (status_update_interval, 1s).
M.toggle_zoom = wezterm.action_callback(function(window, pane)
  local tab = pane:tab()
  if not tab then
    return
  end
  local zoomed = not is_zoomed(tab)
  tab:set_zoomed(zoomed)
  show_tab_bar_when_zoomed(window, zoomed)
end)

function M.apply_to_config(config)
  config.hide_tab_bar_if_only_one_tab = true

  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.show_new_tab_button_in_tab_bar = false
  config.tab_and_split_indices_are_zero_based = false
  config.tab_max_width = 32

  -- tmux-style labels: "1:nvim*", with tmux's Z flag when a pane is zoomed
  wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local title = tab.tab_title ~= '' and tab.tab_title
        or basename(pane.foreground_process_name ~= '' and pane.foreground_process_name or pane.title)
    local marker = (tab.is_active and '*' or ' ') .. (pane.is_zoomed and 'Z' or '')
    local index = (tab.tab_index + 1) % 10
    return string.format(' %d:%s%s ', index, title, marker)
  end)

  -- tmux-like right side (domain/host + time)
  wezterm.on('update-status', function(window, pane)
    show_tab_bar_when_zoomed(window)

    local domain = pane:get_domain_name()
    -- like tmux's client_prefix: flag when the C-b key table is waiting
    local prefix = window:active_key_table() == 'tmux' and ' ^B ' or ''
    window:set_right_status(wezterm.format {
      { Attribute = { Intensity = 'Bold' } },
      { Text = prefix },
      { Attribute = { Intensity = 'Normal' } },
      { Foreground = { Color = status_color(window) } },
      { Text = string.format(' %s  %s ', domain, wezterm.strftime '%H:%M') },
    })
  end)
end

return M
