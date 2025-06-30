local function switch_source_header_splitcmd(bufnr, splitcmd)
  local method_name = 'textDocument/switchSourceHeader'
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
  if not client then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end

  local params = vim.lsp.util.make_text_document_params(bufnr)
  client.request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
  end, bufnr)
end

return {
  {
    -- LSP Configuration & Plugins
    'williamboman/mason.nvim',
    dependencies = {
      'saghen/blink.cmp',
      'neovim/nvim-lspconfig',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    lazy = false,
    config = function()
      --  This function gets run when an LSP connects to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            if desc then
              desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          nmap('<leader>ra', vim.lsp.buf.rename, '[R]en[a]me')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          vim.keymap.set('n', "<leader>]e", function() switch_source_header_splitcmd(0, 'edit') end,
            { noremap = true, desc = "Edit source/header in new tab" })
          vim.keymap.set('n', "<leader>]h", function() switch_source_header_splitcmd(0, 'split') end,
            { noremap = true, desc = "Edit source/header in hsplit" })
          vim.keymap.set('n', "<leader>]v", function() switch_source_header_splitcmd(0, 'vsplit') end,
            { noremap = true, desc = "Edit source/header in vsplit" })

          -- See `:help K` for why this keymap
          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Lesser used LSP functionality
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LSP log level
      vim.lsp.set_log_level(vim.log.levels.WARN)

      -- Show diagnostics in virtual text
      vim.diagnostic.config({ virtual_text = true })

      local servers = {
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          -- Skip cretaing clangd utility user commands
          on_attach = function(_, _) end,
        },
        -- gopls = {},
        basedpyright = {},
        rust_analyzer = {},
        -- tsserver = {},
        -- html = { filetypes = { 'html', 'twig', 'hbs'} },

        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              telemetry = { enable = false },
              diagnostics = {
                gloabls = { 'vim' },
                -- diagnostics = { disable = { 'missing-fields' } },
              }
            },
          },
        },
      }

      -- try loading local lsp server settings. Table should be in same format as above
      local local_lsp = require('custom.helpers').tryRequire('local.lsp_settings')
      if local_lsp ~= nil and local_lsp.lsp_servers ~= nil then
        servers = vim.tbl_deep_extend('force', servers, local_lsp.lsp_servers)
      end

      require('mason').setup()
      require('mason-lspconfig').setup({
        automatic_enable = true,
        ensure_installed = vim.tbl_keys(servers),
      })

      for server_name, config in pairs(servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        vim.lsp.config(server_name, config)
      end

      -- Add blink capabilities to all LSPs not explicitly configured
      vim.lsp.config("*", {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })
    end

  },
}
