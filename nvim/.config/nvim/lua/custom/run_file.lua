local M = {}

local term = require('custom.term')
local term_name = "run_file"

--- Get potential shebang, nil if doesn't exist
---@return string? String with shebang without leading '#!'
local function get_shebang()
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
  if not first_line or not first_line:match('^#!.+') then
    return nil
  end
  return first_line:sub(3, -1)
end

local ft_handler = {
  python = function()
    local interpreter = get_shebang() or "python3"
    return string.format("%s %s", interpreter, vim.api.nvim_buf_get_name(0))
  end
}

local function default_handler()
  local shebang = get_shebang()
  if not shebang then
    return nil
  end

  return string.format("%s %s", shebang, vim.api.nvim_buf_get_name(0))
end

local function get_run_file_command()
  local run_file = vim.fn.getcwd() .. "/" .. "run.vim.sh"
  if vim.fn.filereadable(run_file) == 1 then
    return string.format("bash %s", run_file)
  end
  return nil
end

local function get_command(ft)
  local run_file_command = get_run_file_command()
  if run_file_command then
    return run_file_command
  end

  local handler = ft_handler[ft]
  local command

  if not handler then
    command = default_handler()
    if not command then
      vim.notify(string.format("No run handler for: %s", ft))
      return
    end
  else
    command = handler()
  end
end

--- Run the current file
--- Will save file on call
function M.run_file()
  vim.cmd.write({ mods = { emsg_silent = true, noautocmd = true } })
  local ft = vim.bo.filetype
  if ft == "lua" or ft == "vim" then
    vim.cmd.source('%')
    return
  end

  local command = get_command(ft)
  if not command then
    return
  end

  term.open_term({ name = term_name, focus = false, cmd = command })
end

function M.show_term()
  term.open_term({ name = term_name, focus = false })
end

function M.close_term()
  term.hide_term(term_name)
end

-- Run current file
vim.keymap.set('n', '<leader>xx', M.run_file, { desc = "E[x]ecute file in term" })
vim.keymap.set('n', '<leader>xs', M.show_term, { desc = "E[x]ecute File, show term" })
vim.keymap.set('n', '<leader>xc', M.close_term, { desc = "E[x]ecute File, close term" })

return M
