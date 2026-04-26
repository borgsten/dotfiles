return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { "<leader>c", group = "[C]ode" },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>f", group = "[F]ind" },
        { "<leader>g", group = "[G]it" },
        { "<leader>h", group = "Git [H]unk" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>x", group = "E[X]ecute" },
        -- register which-key VISUAL mode
        -- required for visual <leader>hs (hunk stage) to work
        { "<leader>",  group = "VISUAL <leader>", mode = "v" },
        { "<leader>h", desc = "Git [H]unk",       mode = "v" },
      }
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },
  { "brenoprata10/nvim-highlight-colors", opts = {} },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
      local oil = require('oil')
      oil.setup({})
      local function toggle_oil_in_split()
        if vim.bo.buftype == "oil" then
          oil.close()
        else
          oil.open()
        end
      end
      vim.keymap.set("n", "<leader>:", toggle_oil_in_split, { desc = "Toggle Oil in split" })
      vim.keymap.set("n", "<leader>;", oil.toggle_float, { desc = "Toggle floating Oil" })
    end
  },
}
