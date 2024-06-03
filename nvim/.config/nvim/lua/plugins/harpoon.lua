return {
  {
    "ThePrimeagen/harpoon",
    event = 'VeryLazy',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({})

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end,
        { desc = "[H]arpoon: [A]ppend file to list" })
      vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "[H]arpoon: Toggle [L]ist" })

      for i = 1, 5, 1 do
        vim.keymap.set("n", "<C-" .. i .. ">", function() harpoon:list():select(i) end,
          { desc = "Harpoon: Change to harpoon file " .. i })
      end
    end
  },
}
