local M = {}

---@class TermInfo
---@field buf_id integer
---@field term_id integer

---@type table<string, TermInfo> Keeps track of opened terminals
OpenTerms = OpenTerms or {}

--- Print currently open terminals
function M.list_terms()
  vim.notify("Open terminals(name, bufid)")
  for name, terminfo in pairs(OpenTerms) do
    vim.notify(string.format("%s: %i", name, terminfo.buf_id))
  end
end

---@param name string term name
---@return integer window id if exists, otherwise -1
local function get_term_window(name)
  if OpenTerms[name] then
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winid) == OpenTerms[name].buf_id then
        return winid
      end
    end
  end
  return -1
end

--- Open a terminal as a split
--- If name is not known then a new terminal buffer will be created.
--- If terminal name exists but terminal not open it will be revealed
--- If cmd is set then it will be run otherwise the terminal will only be reaveal
---@param opts{name: string?, focus: boolean?, cmd: string?}?
function M.open_term(opts)
  local name = opts and opts.name or "default_term"
  local focus = opts and opts.focus or false
  local cmd = opts and opts.cmd or nil

  if OpenTerms[name] then
    if get_term_window(name) == -1 then
      vim.api.nvim_open_win(OpenTerms[name].buf_id, focus, {
        split = 'right',
        win = 0
      })
    end
  else
    local win_id = vim.api.nvim_get_current_win()
    local buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf_id, true, {
      split = 'right',
      win = 0
    })
    local term_id = vim.fn.termopen(vim.env.SHELL)
    if not focus then
      vim.api.nvim_set_current_win(win_id)
    end
    OpenTerms[name] = { buf_id = buf_id, term_id = term_id }
  end
  if cmd then
    local buf_id = OpenTerms[name].buf_id
    local term_id = OpenTerms[name].term_id
    local win_id = get_term_window(name)
    vim.api.nvim_chan_send(term_id, cmd .. "\n")
    local target_line = vim.tbl_count(vim.api.nvim_buf_get_lines(buf_id, 0, -1, true))
    vim.api.nvim_win_set_cursor(win_id, { target_line, 0 })
  end
end

---@param name string name of terminal
---@param close_buf boolean? should buffer be closed as well
function M.hide_term(name, close_buf)
  local win_id = get_term_window(name)
  if win_id ~= -1 then
    vim.api.nvim_win_close(win_id, true)
    if close_buf then
      vim.api.nvim_buf_delete(OpenTerms[name].buf_id, {})
      OpenTerms[name] = nil
    end
  end
end

return M
