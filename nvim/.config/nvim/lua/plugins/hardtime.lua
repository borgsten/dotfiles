return {
  "m4xshen/hardtime.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" },
  opts = {
    disable_mouse = false,
    disabled_keys = {
      ["<Up>"] = { "n" },
      ["<Down>"] = { "n" },
      ["<Left>"] = { "n" },
      ["<Right>"] = { "n" },
    },
    restricted_keys = {
      ["h"] = false,
      ["j"] = false,
      ["k"] = false,
      ["l"] = false,
    },
  },
}
