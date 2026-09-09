--- Small reads of the filesystem.
---@class Util.Sys
local M = {}

--- Contents with trailing whitespace trimmed.
---@param path string
---@return string?
function M.readFile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  if content == nil then return nil end
  return (content:gsub("%s+$", ""))
end

---@param path string
---@return number?
function M.readNumber(path)
  local s = M.readFile(path)
  if s == nil then return nil end
  return tonumber(s)
end

---@param paths string[]
---@return string?
function M.firstExisting(paths)
  for _, p in ipairs(paths) do
    local f = io.open(p, "r")
    if f then
      f:close()
      return p
    end
  end
  return nil
end

---@param pattern string
---@return string[]
function M.glob(pattern)
  local out = {}
  -- 2>/dev/null: `ls -d` complains on stderr when a glob matches nothing,
  -- which would otherwise land in Hyprland's log.
  local h = io.popen(("ls -d %s 2>/dev/null"):format(pattern))
  if not h then return out end
  for line in h:lines() do out[#out + 1] = line end
  h:close()
  return out
end

return M
