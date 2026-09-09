--------------------------------------------------------------------------------
---                               SCRATCHPAD                                 ---
--------------------------------------------------------------------------------

---@class Config.Scratchpad
---@field class string   the window's `initial_class`
---@field cmd string     command that spawns it
---@field size? number   fraction of the monitor, 0.0-1.0

local M = {}

---@type table<string, Config.Scratchpad>
local DEFAULTS = {
  scratch = { class = "com.scratch", cmd = "scratch", size = 0.8 },
}

---@type table<string, Util.Scratchpad.Instance>?
local instances = nil

---@return table<string, Util.Scratchpad.Instance>
local function all()
  if instances then return instances end
  instances = {}
  for name, spec in pairs(UTIL.config.section("scratchpads", DEFAULTS)) do
    instances[name] = UTIL.scratchpad.new({
      name  = name,
      class = spec.class,
      cmd   = spec.cmd,
      size  = spec.size,
    })
  end
  return instances
end

--- Resolved at press time, so binds can be declared before setup runs.
---@param name string
---@param action "toggle"|"empty"
---@return fun()
local function forward(name, action)
  return function()
    local instance = all()[name]
    if instance == nil then
      UTIL.dbg.error(("scratch: no scratchpad named %q"):format(name))
      return
    end
    instance[action]()
  end
end

---@param name string
---@return fun()
function M.toggle(name) return forward(name, "toggle") end

---@param name string
---@return fun()
function M.empty(name) return forward(name, "empty") end

function M.setup()
  for _, instance in pairs(all()) do
    instance.setup()
  end
end

return M
