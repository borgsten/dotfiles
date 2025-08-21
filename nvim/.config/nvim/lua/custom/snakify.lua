local M = {}

--- Transform CamelCase to snake_case
---
---@param input string Word that should be converted
---@return string? converted converted word
function M.snake_to_camel(input)
  if string.find(input, ' ') ~= nil then
    vim.notify(string.format("Cannot convert '%s' from snake_case, contains spaces", input), vim.log.levels.WARN)
    return nil
  end
  if string.find(input, '_') == nil then
    vim.notify(string.format("Cannot convert '%s' from snake_case, contains no underscores", input), vim.log.levels.WARN)
    return nil
  end

  while true do
    local underscore, _ = string.find(input, "_")
    if not underscore then
      break
    end

    local converted = string.sub(input, 1, underscore - 1) ..
        string.upper(string.sub(input, underscore + 1, underscore + 1))
    input = converted .. string.sub(input, underscore + 2)
  end
  return input
end

--- Transform snake_case to camelCase
---
---@param input string Word that should be converted
---@return string? converted converted word
function M.camel_to_snake(input)
  if string.find(input, ' ') ~= nil then
    vim.notify(string.format("Cannot convert '%s' to camelCase, contains spaces", input), vim.log.levels.WARN)
    return nil
  end
  if string.find(input, '%u') == nil then
    vim.notify(string.format("Cannot convert '%s' to camelCase, contains no upper case letters", input),
      vim.log.levels.WARN)
    return nil
  end

  while true do
    local u_case, _ = string.find(input, "%u")
    if not u_case then
      break
    end

    local converted = string.sub(input, 1, u_case - 1) .. '_' ..
        string.lower(string.sub(input, u_case, u_case))
    input = converted .. string.sub(input, u_case + 1)
  end
  return input
end

-- Use anonymous function on word under cursor
--
--@param function function function to be used on word
function M.operate_on_word(func)
  local current_word = vim.fn.expand("<cword>")
  local converted = func(current_word)

  if converted == nil then
    return
  end

  vim.cmd(string.format("silent! execute 'normal! ciw%s'", converted))
end

function M.setup()
  vim.keymap.set("n", "<leader>ts", function()
    M.operate_on_word(M.camel_to_snake)
  end, { desc = "Convert word under cursor to snake case" })
  vim.keymap.set("n", "<leader>tc", function()
    M.operate_on_word(M.snake_to_camel)
  end, { desc = "Convert word under cursor to camel case" })
end

return M
