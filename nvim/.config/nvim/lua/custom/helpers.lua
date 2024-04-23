local M = {}

--- Convert an environment variables value to a lua list
---
--- Will trim empty parts
---@param environ_key string Key of environment variable
---@return string[] List environment varaible split into list
function M.envToList(environ_key)
  local value = os.getenv(environ_key)
  if value == nil then
    return {}
  end
  return vim.split(value, ':', { trimempty = true })
end

--- Create table from list of envvar keys
---
--- Will skip non existant keys
---@param environ_keys string[] List of envvar keys
---@return table<string, string> Table with keys from argument and their corresponding envvar values
function M.envListToTable(environ_keys)
  local table = {}
  for _, env_key in pairs(environ_keys) do
    local env_value = os.getenv(env_key)
    if env_value ~= nil then
      table[env_key] = env_value
    end
  end
  return table
end

--- Read string from XResources
---
--- Will return first match
---@param key string XResources key
---@return string? string the value from the key
function M.readFromXResources(key)
  local result = io.popen("xrdb -query | grep " .. key .. " | cut -f 2")
  if result == nil then
    return nil
  end
  local value = result:read("*l")
  if value == nil then
    return nil
  end
  return value
end

--- Try require module
---
--- If not possible then will return nil
---@param module_name string module name
---@return any? module the module or nil
function M.tryRequire(module_name)
  local success, module = pcall(require, module_name)
  if success then
    return module
  else
    return nil
  end
end

return M
