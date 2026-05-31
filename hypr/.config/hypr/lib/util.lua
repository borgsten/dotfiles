local M = {}

--- Check if a command exists in path
---@param cmd string
---@return boolean
function M.cmd_exists(cmd)
  for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    if io.open(dir .. "/" .. cmd, "r") then return true end
  end
  return false
end

return M
