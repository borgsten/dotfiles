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
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        theme = "dragon"
      })
    end,
  },
  { "rose-pine/neovim", name = "rose-pine" },
  { "catppuccin/nvim",  name = "catppuccin", priority = 1000 },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },
  { "brenoprata10/nvim-highlight-colors", opts = {} },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true
      });
      require('which-key').add({ '<leader>e', mode = 'n', ":Neotree reveal toggle=true<CR>", desc = "Toggle neotree" })
    end
  },
}
