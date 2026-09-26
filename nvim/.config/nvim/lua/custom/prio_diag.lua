-- Cycle through all diagnostics in the buffer ordered by severity, then position.
-- Inspired by https://github.com/5long/dotfiles/blob/trunk/nvim/lua/config/prioritized_diagnostic.lua
local d = vim.diagnostic

local M = {}

-- Last diagnostic jumped to, used to resume the cycle when the cursor hasn't moved
local last = nil

local function same_diag(a, b)
  return a.lnum == b.lnum and a.col == b.col and a.severity == b.severity and a.message == b.message
end

--- All diagnostics in the buffer, most severe first, then by position
local function sorted_diagnostics(bufnr)
  local diags = d.get(bufnr)
  table.sort(diags, function(a, b)
    if a.severity ~= b.severity then
      return a.severity < b.severity -- ERROR = 1 ... HINT = 4
    end
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end
    return a.col < b.col
  end)
  return diags
end

--- Index of the diagnostic we are currently "on" in the cycle, or nil
local function current_index(diags, bufnr, cursor)
  if not last or last.bufnr ~= bufnr or last.cursor[1] ~= cursor[1] or last.cursor[2] ~= cursor[2] then
    return nil
  end
  for i, diag in ipairs(diags) do
    if same_diag(diag, last.diag) then
      return i
    end
  end
end

--- Starting point when not in a cycle: the nearest diagnostic of the highest
--- severity in the given direction from the cursor (wrapping around)
local function entry_index(diags, cursor, forward)
  local top = diags[1].severity
  local row, col = cursor[1] - 1, cursor[2]
  local first, last_idx, found
  for i, diag in ipairs(diags) do
    if diag.severity ~= top then
      break
    end
    first = first or i
    last_idx = i
    local after = diag.lnum > row or (diag.lnum == row and diag.col > col)
    local before = diag.lnum < row or (diag.lnum == row and diag.col < col)
    if forward and after and not found then
      found = i
    elseif not forward and before then
      found = i
    end
  end
  return found or (forward and first or last_idx)
end

local function jump(step)
  local bufnr = vim.api.nvim_get_current_buf()
  local diags = sorted_diagnostics(bufnr)
  if #diags == 0 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local idx = current_index(diags, bufnr, cursor)
  if idx then
    idx = (idx - 1 + step) % #diags + 1
  else
    idx = entry_index(diags, cursor, step > 0)
    -- The entry point counts as the first step
    local rest = step > 0 and step - 1 or step + 1
    idx = (idx - 1 + rest) % #diags + 1
  end

  local diag = diags[idx]
  d.jump({ diagnostic = diag })
  last = { bufnr = bufnr, diag = diag, cursor = vim.api.nvim_win_get_cursor(0) }
end

--- Jump to the next diagnostic based on priority
function M.jump_next()
  jump(vim.v.count1)
end

--- Jump to the previous diagnostic based on priority
function M.jump_prev()
  jump(-vim.v.count1)
end

return M
