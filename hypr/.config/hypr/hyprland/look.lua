--------------------------------------------------------------------------------
---                             LOOK AND FEEL                                ---
--------------------------------------------------------------------------------

-- https://wiki.hyprland.org/Configuring/Variables/

local theme_path = os.getenv("HOME") .. "/.cache/theming"
package.path = theme_path .. "/?.lua;" .. package.path
local theme = require("hyprland_theme")

--- The theme exports decimal `rgb(r,g,b)`; Hyprland only takes alpha in the
--- hex `rgba(rrggbbaa)` form.
---@param color string an `rgb(r,g,b)` value from the theme
---@param alpha number 0.0 - 1.0
---@return string
local function fade(color, alpha)
  local r, g, b = color:match("^rgba?%((%d+),%s*(%d+),%s*(%d+)")
  if not r then
    return color
  end
  return string.format("rgba(%02x%02x%02x%02x)",
    tonumber(r), tonumber(g), tonumber(b), math.floor(alpha * 255 + 0.5))
end

-- Active tabs are light surfaces under dark text, so fading moves them toward
-- the text: 0.75 is the floor before the title drops under WCAG AA (4.6:1).
-- Inactive tabs fade away from their text, so they have more room.
local TAB_ALPHA_ACTIVE   = 0.75
local TAB_ALPHA_INACTIVE = 0.85

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
      -- Defaults (height 14 / font_size 8) are too small to read.
      height            = 20,
      font_size         = 11,
      text_padding      = 6,
      render_titles     = true,
      -- Kept on single-tab groups: the only cue that a window is grouped.
      disable_when_only = false,

      -- Without gradients Hyprland paints only the indicator line and leaves
      -- the tab transparent, so titles have nothing to sit on.
      gradients         = true,
      indicator_height  = 0,

      -- Square, to match decoration.rounding = 0.
      rounding          = 0,
      gradient_rounding = 0,

      -- Each surface paired with its matching `on*` foreground, so contrast
      -- holds for any generated palette.
      text_color                 = theme.onPrimary,        -- on primary
      text_color_inactive        = theme.onSurfaceVariant, -- on surfaceContainerHigh
      text_color_locked_active   = theme.onError,          -- on error
      text_color_locked_inactive = theme.onErrorContainer, -- on errorContainer
      col                        = {
        active          = fade(theme.primary, TAB_ALPHA_ACTIVE),
        inactive        = fade(theme.surfaceContainerHigh, TAB_ALPHA_INACTIVE),
        locked_active   = fade(theme.error, TAB_ALPHA_ACTIVE),
        locked_inactive = fade(theme.errorContainer, TAB_ALPHA_INACTIVE),
      },
    },
  },
})
