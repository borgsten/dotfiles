--- Pure table operations: nothing here touches Hyprland or the filesystem.
---@class Util.Tbl
local M = {}

--- Recursive copy. Metatables are not carried over, so this is for plain data.
---@generic T
---@param value T
---@return T
function M.copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = M.copy(v) end
  return out
end

--- Tests for a `[1]`, not for emptiness: `{}` as an override has to mean
--- "change nothing" rather than "replace with an empty list".
---@param value any
---@return boolean
function M.isList(value)
  return type(value) == "table" and value[1] ~= nil
end

--- Lay `override` over `defaults`. Maps merge recursively, **lists replace
--- wholesale** -- a machine declaring one monitor must not inherit a second
--- from the defaults.
---@generic T
---@param defaults T
---@param override any
---@return T
function M.merge(defaults, override)
  if override == nil then return M.copy(defaults) end
  if type(override) ~= "table" or type(defaults) ~= "table" then
    return M.copy(override)
  end
  if M.isList(override) or M.isList(defaults) then return M.copy(override) end

  local out = {}
  for k, v in pairs(defaults) do out[k] = M.copy(v) end
  for k, v in pairs(override) do out[k] = M.merge(defaults[k], v) end
  return out
end

---@param a any
---@param b any
---@return boolean
function M.deepEqual(a, b)
  if a == b then return true end
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return false end

  for k, v in pairs(a) do
    if not M.deepEqual(v, b[k]) then return false end
  end
  for k, v in pairs(b) do
    if not M.deepEqual(v, a[k]) then return false end
  end
  return true
end

return M
