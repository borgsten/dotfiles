return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        'saghen/blink.cmp',
        opts = {
          sources = {
            per_filetype = {
              codecompanion = { "codecompanion" },
            }
          },
        }
      },
      {
        "OXY2DEV/markview.nvim",
        opts = {
          preview = {
            filetypes = { "markdown", "codecompanion" },
            ignore_buftypes = {},
          },
        },
      }
    },
    opts = {
      -- NOTE: The log_level is in `opts.opts`
      opts = {
        log_level = "DEBUG", -- or "TRACE"
      },
    },
    keys = {
      { "<leader>cc", ":CodeCompanionChat Toggle<CR>", desc = "Toggle [C]ode [C]ompanion chat",
      },
    },
  },
}
