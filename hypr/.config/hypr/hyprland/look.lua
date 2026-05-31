--------------------------------------------------------------------------------
---                             LOOK AND FEEL                                ---
--------------------------------------------------------------------------------

-- https://wiki.hyprland.org/Configuring/Variables/

-- local theme = {}
-- local f = io.open(os.getenv("HOME") .. "/.cache/theming/hypr.conf", "r")
-- if f then
--   for line in f:lines() do
--     local key, val = line:match("^%$(%w+)%s*=%s*(.+)")
--     if key then theme[key] = val:gsub("%s+$", "") end
--   end
--   f:close()
-- end

local theme_path = os.getenv("HOME") .. "/.cache/theming"
package.path = theme_path .. "/?.lua;" .. package.path
local theme = require("hyprland_theme")

-- https://wiki.hyprland.org/Configuring/Variables/#general
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 0,
    border_size = 2,
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
    col = {
      active_border   = theme.primary,
      inactive_border = theme.outline,
    },
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#decoration
  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    dim_special = 0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#animations
  animations = {
    enabled = false,
  },

  group = {
    col      = {
      border_active          = theme.primary,
      border_inactive        = theme.outline,
      border_locked_active   = theme.error,
      border_locked_inactive = theme.outline,
    },
    groupbar = {
      col = {
        active          = theme.primary,
        inactive        = theme.outline,
        locked_active   = theme.error,
        locked_inactive = theme.outline,
      },
    },
  },
})
