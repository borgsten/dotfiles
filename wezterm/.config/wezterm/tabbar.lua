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

function M.apply_to_config(config)
  config.hide_tab_bar_if_only_one_tab = true

  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.show_new_tab_button_in_tab_bar = false
  config.tab_and_split_indices_are_zero_based = false
  config.tab_max_width = 32

  -- tmux-style labels: "0:nvim*"
  wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local title = tab.tab_title ~= '' and tab.tab_title
        or basename(pane.foreground_process_name ~= '' and pane.foreground_process_name or pane.title)
    local marker = tab.is_active and '*' or ' '
    local index = (tab.tab_index + 1) % 10
    return string.format(' %d:%s%s ', index, title, marker)
  end)

  -- tmux-like right side (domain/host + time)
  wezterm.on('update-status', function(window, pane)
    local domain = pane:get_domain_name()
    window:set_right_status(wezterm.format {
      { Foreground = { Color = status_color(window) } },
      { Text = string.format(' %s  %s ', domain, wezterm.strftime '%H:%M') },
    })
  end)
end

return M
