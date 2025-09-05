return {
  {
    'stevearc/conform.nvim',
    config = function()
      local formatters = {}
      local local_formatters = require('custom.helpers').tryRequire('local.formatters')
      if local_formatters ~= nil and local_formatters.formatters ~= nil then
        formatters = vim.tbl_deep_extend('force', formatters, local_formatters.formatters)
      end

      require('conform').setup({
        notify_on_error = false,
        format_on_save = function(bufnr)
          local autofortmat_ft = { 'lua', 'go' }
          if not vim.tbl_contains(autofortmat_ft, vim.bo[bufnr].filetype) then
            return
          end
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_fallback = true, }
        end,
        formatters = formatters,
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', "black" },
          cpp = { "clang_format" },
        },
      })

      vim.api.nvim_create_user_command('Format', function(_)
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = 'Format current buffer with LSP' })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save(bang for buffer)",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })

      vim.keymap.set({ 'n', 'v' }, "<leader>fm", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format document" })
    end
  },
}
