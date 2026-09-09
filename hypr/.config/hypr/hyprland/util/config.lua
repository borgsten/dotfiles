--- Resolving configuration sections. Generic: the schema lives in
--- `hyprland/config.lua`, this knows only how to merge a section over defaults.
---@class Util.Config
local M = {}

---@type table?
local raw = nil
---@type table<string, table>
local sections = {}

---@return table
local function readLocal()
  if raw then return raw end

  -- searchpath first: an absent local config is normal and stays quiet, a
  -- present but broken one must be loud.
  if not package.searchpath("hyprland.local.config", package.path) then
    raw = {}
    return raw
  end

  -- osd rather than notify-send: config evaluation can run before any
  -- notification daemon is up.
  local ok, cfg = pcall(require, "hyprland.local.config")
  if not ok then
    UTIL.notif.osd("Broken local config: " .. tostring(cfg), { timeout = 15000 })
    cfg = {}
  elseif type(cfg) ~= "table" then
    UTIL.notif.osd("Local config did not return a table", { timeout = 15000 })
    cfg = {}
  end

  raw = cfg
  return raw
end

--- The machine's overrides laid over the defaults the calling module owns.
--- Memoised, so reading the same section from several modules is free.
--- See `UTIL.tbl.merge` for the merge rule -- notably that lists replace.
---@generic T: table
---@param name string
---@param defaults T
---@return T
function M.section(name, defaults)
  if sections[name] == nil then
    sections[name] = UTIL.tbl.merge(defaults, readLocal()[name])
  end
  return sections[name]
end

return M
