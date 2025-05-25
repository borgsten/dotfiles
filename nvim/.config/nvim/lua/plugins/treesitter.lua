return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { 'c', 'cpp', 'lua', 'python', 'rust', 'vimdoc', 'vim', 'bash', 'markdown', 'markdown_inline', 'css', 'make', 'cmake', 'rust', 'vimdoc', 'yaml', 'json', 'luadoc', 'query', 'diff' },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
