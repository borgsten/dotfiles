local M = {}

--- Check if a command exists in path
---@param cmd string
---@return boolean
function M.cmd_exists(cmd)
  for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    local f = io.open(dir .. "/" .. cmd, "r")
    if f then f:close(); return true end
  end
  return false
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
