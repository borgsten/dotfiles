local wezterm = require 'wezterm'

local M = {}

-- NOTE: the plugin appends to config.keys, so any config.keys = {...} of your
-- own has to be assigned BEFORE this runs or it gets wiped out.
function M.apply_to_config(config)
  local smart_splits = wezterm.plugin.require 'https://github.com/mrjones2014/smart-splits.nvim'

  smart_splits.apply_to_config(config, {
    direction_keys = { 'h', 'j', 'k', 'l' },
    modifiers = { move = 'CTRL', resize = 'META' },
  })
end

return M
