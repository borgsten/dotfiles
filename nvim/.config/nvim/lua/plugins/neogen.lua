return {
  "danymat/neogen",
  dependencies = { "L3MON4D3/LuaSnip" },
  config = function()
    local neogen = require("neogen")
    neogen.setup({ snippet_engine = "luasnip" })
    vim.keymap.set("n", "<leader>ga", neogen.generate, { desc = "[G]enerate [A]nnotation" })
  end,
  -- Uncomment next line if you want to follow only stable versions
  -- version = "*"
}
