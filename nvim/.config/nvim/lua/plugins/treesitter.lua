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

    -- Auto command to enable TS highlighting for installed languages
    vim.api.nvim_create_autocmd('FileType', {
      pattern = ts.get_installed(),
      callback = function() vim.treesitter.start() end,
    })
  end
}
