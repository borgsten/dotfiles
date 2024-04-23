return {
  {
    "ThePrimeagen/harpoon",
    event = 'VeryLazy',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({})

      vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "Append file to harpoon list" })
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Toggle harpoon list" })

      for i = 1, 5, 1 do
        vim.keymap.set("n", "<C-" .. i .. ">", function() harpoon:list():select(i) end,
          { desc = "Change to harpoon file " .. i })
      end

      -- Toggle previous & next buffers stored within harpoon list
      vim.keymap.set("n", "<C-S-[>", function() harpoon:list():prev() end, { desc = "Previous harpoon file" })
      vim.keymap.set("n", "<C-S-]>", function() harpoon:list():next() end, { desc = "Next harpoon file" })
    end
  },
}
