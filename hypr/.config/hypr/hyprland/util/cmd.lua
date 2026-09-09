--- Factories for the command-shaped actions that shell backends are made of.
---@class Util.Cmd
local M = {}

--- `prefixed("noctalia msg")("volume-up 3")` -> exec_cmd("noctalia msg volume-up 3")
---@param prefix string
---@return fun(args?: string): HL.Dispatcher
function M.prefixed(prefix)
  return function(args)
    local cmd = args and (prefix .. " " .. args) or prefix
    return hl.dsp.exec_cmd(cmd)
  end
end

--- Returns a function rather than a dispatcher: the monitor name is only known
--- at press time. `template` takes one `%s`.
---@param template string
---@return fun(args: string): fun()
function M.perMonitor(template)
  return function(args)
    return function()
      local mon = hl.get_active_monitor()
      if mon == nil then
        UTIL.dbg.warn("cmd.perMonitor: no active monitor, skipping: " .. args)
        return
      end
      hl.dispatch(hl.dsp.exec_cmd(template:format(mon.name) .. " " .. args))
    end
  end
end

return M
