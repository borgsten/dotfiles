--- JSON encoding of plain data. Uses nothing from Hyprland or UTIL, so plain
--- `lua` can load it too: `hyprlocal` reads the local config through it.
---@class Util.Json
local M = {}

---@param s string
---@return string
local function quote(s)
    return '"' .. s:gsub('[%c"\\]', function(c)
        return ('\\u%04x'):format(c:byte())
    end) .. '"'
end

--- Same rule as `UTIL.tbl.isList`, so `{}` encodes as an object.
---@param t table
---@return boolean
local function isList(t)
    return t[1] ~= nil
end

--- Floats keep a fractional part, so `1.0` does not come back as an integer.
---@param n number
---@return string
local function number(n)
    if math.type(n) ~= 'float' then
        return tostring(n)
    end
    local s = ('%.17g'):format(n)
    return s:find('[.e]') and s or (s .. '.0')
end

---@param value any  nil, boolean, number, string or a table of those
---@return string
function M.encode(value)
    local t = type(value)
    if t == 'table' then
        local parts = {}
        if isList(value) then
            for _, v in ipairs(value) do
                parts[#parts + 1] = M.encode(v)
            end
            return '[' .. table.concat(parts, ',') .. ']'
        end
        for k, v in pairs(value) do
            parts[#parts + 1] = quote(tostring(k)) .. ':' .. M.encode(v)
        end
        return '{' .. table.concat(parts, ',') .. '}'
    elseif t == 'string' then
        return quote(value)
    elseif t == 'number' then
        return number(value)
    elseif t == 'nil' then
        return 'null'
    end
    return tostring(value)
end

return M
