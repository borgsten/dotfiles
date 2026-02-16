return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local filetypes = {
      'bash',
      'c',
      'cmake',
      'cpp',
      'css',
      'diff',
      'go',
      'html',
      'json',
      'lua',
      'luadoc',
      'make',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'rust',
      'vim',
      'vimdoc',
      'yaml',
    }
    local ts = require('nvim-treesitter')
    ts.setup()
    ts.install(filetypes)
  end,
}
