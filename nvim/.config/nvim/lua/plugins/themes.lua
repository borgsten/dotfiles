return {
  { 'rose-pine/neovim', name = 'rose-pine', priority = 1000 },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  { 'folke/tokyonight.nvim', priority = 1000 },
  -- Recoloured from the generated palette
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('custom.generated_theme').setup({ transparent = true })
    end,
  },
}
