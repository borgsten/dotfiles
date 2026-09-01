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

--- Re-emit a theme color at reduced opacity. The theme exports decimal
--- "rgb(r,g,b)" triplets, while Hyprland only takes an alpha channel in the
--- hex "rgba(rrggbbaa)" form, so this converts between the two.
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

-- Opacity of the groupbar tabs. The fully opaque Material You surfaces read
-- as a harsh slab of color against the rest of the desktop; letting a little
-- of the backdrop through settles them down. Titles stay fully opaque, so
-- this softens the block without giving back the legibility it buys.
--
-- The active tabs are the loud ones -- they are light surfaces carrying dark
-- text, so fading them moves the tab toward the text and costs contrast.
-- 0.75 is the floor before the title drops under WCAG AA (4.6:1). The
-- inactive tabs are dark surfaces carrying light text, so fading them moves
-- *away* from the text and reads fine wherever it lands.
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
      -- The groupbar is the tab bar of an i3 tabbed container, so make the
      -- titles actually readable (defaults are height 14 / font_size 8).
      height            = 20,
      font_size         = 11,
      text_padding      = 6,
      render_titles     = true,
      -- Keep the bar on single-tab groups: it is the only cue that a window
      -- is a group, which matters now that groups are explicit.
      disable_when_only = false,

      -- Without gradients Hyprland paints only the thin indicator line and
      -- leaves the tab itself transparent, so the title had nothing to sit
      -- on. Filling the tab is what makes the text legible.
      gradients         = true,
      indicator_height  = 0,

      -- Square, to match decoration.rounding = 0.
      rounding          = 0,
      gradient_rounding = 0,

      -- Each tab pairs a Material You surface with its matching `on*`
      -- foreground, so contrast holds for any generated palette rather than
      -- just this one.
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
