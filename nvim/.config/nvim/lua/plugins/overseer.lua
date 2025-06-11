local function rerun_last_task()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end

return {
  'stevearc/overseer.nvim',
  commands = { "OverseerToggle", "OverseerRun" },
  dependencies = { "nvim-telescope/telescope.nvim", "stevearc/dressing.nvim" },
  opts = {},
  keys = {
    { "<leader>os", "<cmd>OverseerToggle!<cr>" },
    { "<leader>or", rerun_last_task },
    { "<leader>ot", "<cmd>OverseerRun<cr>" },
  }
}
