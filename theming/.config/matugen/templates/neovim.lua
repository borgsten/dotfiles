-- Rendered to ~/.cache/theming/neovim.lua. Raw palette roles only; the mapping
-- onto kanagawa lives in nvim (lua/custom/generated_theme.lua), which falls
-- back to stock kanagawa when this file doesn't exist.
return {
  background = '{{colors.background.default.hex}}',
  surface_container_lowest = '{{colors.surface_container_lowest.default.hex}}',
  surface_container_low = '{{colors.surface_container_low.default.hex}}',
  surface_container = '{{colors.surface_container.default.hex}}',
  surface_container_high = '{{colors.surface_container_high.default.hex}}',
  surface_container_highest = '{{colors.surface_container_highest.default.hex}}',

  on_surface = '{{colors.on_surface.default.hex}}',
  on_surface_variant = '{{colors.on_surface_variant.default.hex}}',
  outline = '{{colors.outline.default.hex}}',
  outline_variant = '{{colors.outline_variant.default.hex}}',

  primary = '{{colors.primary.default.hex}}',
  secondary = '{{colors.secondary.default.hex}}',
  tertiary = '{{colors.tertiary.default.hex}}',
  error = '{{colors.error.default.hex}}',
}
