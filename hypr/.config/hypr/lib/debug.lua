local M = {}

-- ---------------------------------------------------------------------------
-- inspect: vim.inspect-style pretty printer for arbitrary values
-- ---------------------------------------------------------------------------
local function is_identifier(k)
  return type(k) == "string" and k:match("^[%a_][%w_]*$") ~= nil
end

local function quote(s)
  return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
    local map = {
      ['"'] = '\\"',
      ['\\'] = '\\\\',
      ['\n'] = '\\n',
      ['\r'] = '\\r',
      ['\t'] = '\\t'
    }
    return map[c] or string.format('\\%03d', c:byte())
  end) .. '"'
end

local function inspect(value, opts)
  opts = opts or {}
  local indent = opts.indent or "  "
  local seen = {}

  local function fmt(v, depth)
    local t = type(v)
    if t == "string" then
      return quote(v)
    elseif t == "number" or t == "boolean" or t == "nil" then
      return tostring(v)
    elseif t ~= "table" then
      return "<" .. t .. ">" -- functions, userdata, threads
    end

    -- table
    if seen[v] then
      return "<cycle " .. tostring(v) .. ">"
    end
    seen[v]      = true

    local pad    = indent:rep(depth + 1)
    local padEnd = indent:rep(depth)
    local parts  = {}

    -- array part first
    local n      = 0
    for i, item in ipairs(v) do
      parts[#parts + 1] = pad .. fmt(item, depth + 1)
      n = i
    end
    -- hash part (sorted for stable output)
    local keys = {}
    for k in pairs(v) do
      if not (type(k) == "number" and k >= 1 and k <= n and k % 1 == 0) then
        keys[#keys + 1] = k
      end
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do
      local key = is_identifier(k) and k or ("[" .. fmt(k, depth + 1) .. "]")
      parts[#parts + 1] = pad .. key .. " = " .. fmt(v[k], depth + 1)
    end

    seen[v] = nil
    if #parts == 0 then return "{}" end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. padEnd .. "}"
  end

  return fmt(value, 0)
end

M.inspect = inspect

-- ---------------------------------------------------------------------------
-- log: arbitrary args, auto-formatted, to print and/or a file
-- ---------------------------------------------------------------------------
M.outfile = nil   -- set M.outfile = "/tmp/hypr-debug.log" to log to file
M.to_print = true -- also emit via print()
M.use_timestamp = true

local LEVELS = { trace = 1, debug = 2, info = 3, warn = 4, error = 5 }
M.level = "warn" -- minimum level to emit

local function stringify(v)
  local t = type(v)
  if t == "string" then return v end
  if t == "table" then return inspect(v) end
  return tostring(v)
end

local function emit(level, ...)
  if (LEVELS[level] or 0) < (LEVELS[M.level] or 0) then return end

  local n = select("#", ...)
  local pieces = {}
  for i = 1, n do
    pieces[i] = stringify((select(i, ...)))
  end
  local body = table.concat(pieces, " ")

  local prefix = string.format("[%-5s]", level:upper())
  if M.use_timestamp then
    prefix = os.date("%Y-%m-%d %H:%M:%S ") .. prefix
  end
  -- caller location, if available
  local info = debug and debug.getinfo and debug.getinfo(3, "Sl")
  if info and info.short_src then
    prefix = prefix .. " " .. info.short_src .. ":" .. (info.currentline or "?")
  end

  local line = prefix .. " " .. body

  if M.to_print then print(line) end

  if M.outfile then
    local fh = io.open(M.outfile, "a")
    if fh then
      fh:write(line, "\n")
      fh:close()
    end
  end
end

M.trace       = function(...) emit("trace", ...) end
M.debug       = function(...) emit("debug", ...) end
M.info        = function(...) emit("info", ...) end
M.warn        = function(...) emit("warn", ...) end
M.error       = function(...) emit("error", ...) end

-- quick dump: print inspect() of anything and return it (chainable)
M.dump        = function(v)
  emit("debug", inspect(v))
  return v
end

-- raw print of arbitrary types, no level/prefix
M.p           = function(...)
  local n = select("#", ...)
  local pieces = {}
  for i = 1, n do pieces[i] = stringify((select(i, ...))) end
  local line = table.concat(pieces, " ")
  if M.to_print then print(line) end
  if M.outfile then
    local fh = io.open(M.outfile, "a")
    if fh then
      fh:write(line, "\n"); fh:close()
    end
  end
end

M.enableDebug = function()
  -- Read logs from "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
  M.level = "trace"
  M.outfile = "/tmp/hyprland.txt"
  hl.config({
    debug = { disable_logs = false }
  })
end

return M
