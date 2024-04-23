local M = {}

HIGHLIGHT_NAME = "Trailspace"
FIND_PATTERN = [[\s\+$]]

local function get_hl_color_from_colorscheme()
  local hl = vim.api.nvim_get_hl(0, { name = "Error" })
  return { bg = hl.fg }
end

local function create_highlight()
  vim.api.nvim_set_hl(0, HIGHLIGHT_NAME, get_hl_color_from_colorscheme())
end

local function get_hl_id()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == HIGHLIGHT_NAME then
      return match.id
    end
  end
  return nil
end

function M.enableHL()
  -- Only enable highlight if the buffer is not a special buffer and doesn't alreay exist
  local buftype = vim.bo.buftype
  if buftype == '' and not get_hl_id() then
    vim.fn.matchadd(HIGHLIGHT_NAME, FIND_PATTERN)
  end
end

function M.disableHL()
  local hl_id = get_hl_id()
  if hl_id then
    vim.fn.matchdelete(hl_id)
  end
end

function M.remove_trailing_whitespace()
  local start_line, end_line

  -- Check if there is a visual selection
  if vim.fn.mode() == 'V' then
    start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
  else
    start_line, end_line = 1, vim.fn.line("$")
  end
  local pattern = [[s/\s\+$//e]]
  print(start_line, end_line)
  vim.cmd(string.format(":%d,%d%s", start_line, end_line, pattern))
end

function M.setup()
  -- Clears old autogroup
  local autogroup = vim.api.nvim_create_augroup(HIGHLIGHT_NAME, { clear = true })

  create_highlight()

  vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "WinEnter" },
    { group = autogroup, callback = M.enableHL, desc = "(Re)Enable highlight" })
  vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave', 'InsertEnter' },
    { group = autogroup, callback = M.disableHL, desc = "Disable highlight" })

  -- Reload color from colorscheme
  vim.api.nvim_create_autocmd("ColorScheme",
    { group = autogroup, callback = create_highlight, desc = "Recreate hihglight group" })
end

return M
