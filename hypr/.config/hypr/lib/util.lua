local M = {}

--- Check if a command exists in path
---@param cmd string
---@return boolean
function M.cmd_exists(cmd)
  for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    local f = io.open(dir .. "/" .. cmd, "r")
    if f then
      f:close(); return true
    end
  end
  return false
end

--- Check if a systemd service is active
---@param service string
---@param user boolean user or system service
---@return boolean
function M.service_active(service, user)
  local scope = user and "--user " or ""
  local cmd = ("systemctl %sis-active %s 2>/dev/null"):format(scope, service)
  local h = io.popen(cmd)
  if h == nil then
    print("Could not run systemctl commnad")
    return false
  end
  local out = h:read("*a")
  h:close()
  return out:match("^active")
end

--- Resize floating window to percent of active monitor
---@param width number between 0.0 - 1.0
---@param height number between 0.0 - 1.0
---@param center boolean? center window as well
---@return function
function M.ResizePercent(width, height, center)
  return function()
    if center then
      hl.dispatch(hl.dsp.window.center())
    end

    local mon = hl.get_active_monitor()
    if mon == nil then return end

    local scaled_width = math.floor(mon.width / mon.scale)
    local scaled_height = math.floor(mon.height / mon.scale)

    local w = math.floor(scaled_width * width)
    local h = math.floor(scaled_height * height)

    hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
  end
end

return M
