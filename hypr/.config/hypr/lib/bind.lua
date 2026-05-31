local M = {}

M.ALT = "ALT"
M.CTRL = "CONTROL"
M.SHFT = "SHIFT"
M.SPR = "SUPER"

---@alias M.Mod
---| `M.ALT`
---| `M.CTRL`
---| `M.SHFT`
---| `M.SPR`

--- Keybind helper
---@param mods M.Mod|M.Mod[]
---@param key string|string[]
---@param action function|HL.Dispatcher
---@param desc string?
---@param opts HL.BindOptions?
function M.bind(mods, key, action, desc, opts)
  opts = opts or {}

  if desc then
    opts.desc = desc
  end

  if type(mods) == "string" then mods = { mods } end
  if type(key) == "string" then key = { key } end

  local parts = table.concat(mods, " + ")
  local prefix = parts ~= "" and parts .. " + " or ""

  for _, k in ipairs(key) do
    local combo = prefix .. k
    hl.bind(combo, action, opts)
  end
end

return M
