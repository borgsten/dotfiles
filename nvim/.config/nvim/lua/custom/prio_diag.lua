-- https://github.com/5long/dotfiles/blob/trunk/nvim/lua/config/prioritized_diagnostic.lua
local d = vim.diagnostic

local M = {}
M.severity_order = {
  d.severity.ERROR,
  d.severity.WARN,
  d.severity.INFO,
  d.severity.HINT,
}

local function get_highest_severity(count)
  count = count or d.count()

  for _, s in ipairs(M.severity_order) do
    if count[s] and count[s] > 0 then
      return s
    end
  end

  return nil
end

--- Jump to the next diagnostic based on priority
function M.jump_next()
  local severity = get_highest_severity()
  d.jump({ count = vim.v.count1, severity = severity })
end

--- Jump to the previous diagnostic based on priority
function M.jump_prev()
  local severity = get_highest_severity()
  d.jump({ count = -vim.v.count1, severity = severity })
end

return M
