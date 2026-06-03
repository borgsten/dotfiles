-- load all local lua files
local dir = debug.getinfo(1, "S").source:match("@(.+)/[^/]+$")
local f = io.popen("ls " .. dir .. "/*.lua 2>/dev/null")
if f then
  for path in f:lines() do
    if not path:match("init%.lua$") and not path:match("config%.lua$") then
      local mod = path:match(".+/(.+)%.lua$")
      require("hyprland.local." .. mod)
    end
  end
  f:close()
end
