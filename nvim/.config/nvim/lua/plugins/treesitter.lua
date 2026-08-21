local function ts_reinstall(lang)
  if not lang or lang == "" then
    vim.notify("Usage: :TSReinstall <parser>", vim.log.levels.ERROR)
    return
  end

  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    vim.notify("nvim-treesitter.parsers is not available", vim.log.levels.ERROR)
    return
  end

  vim.notify(
    string.format("Reinstalling tree-sitter parser '%s', details:\n %s", lang, vim.inspect(parsers[lang])),
    vim.log.levels.INFO
  )
  require('nvim-treesitter').install({ lang }, { force = true, generate = true })
end

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = "main",
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

    vim.api.nvim_create_user_command("TSReinstall", function(opts)
      ts_reinstall(opts.args)
    end, {
      nargs = 1,
      complete = function()
        package.loaded["nvim-treesitter.parsers"] = nil
        vim.api.nvim_exec_autocmds("User", { pattern = "TSUpdate" })
        return vim.tbl_keys(require("nvim-treesitter.parsers"))
      end,
      desc = "Reinstall a tree-sitter parser",
    })
  end
}
