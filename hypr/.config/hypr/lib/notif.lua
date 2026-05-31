local M = {}

---@alias M.Crit "low" | "normal" | "critical"

---@class M.Opts
---@field timeout? integer
---@field icon? string
---@field transient? boolean
---@field criticality? M.Crit

--- Send notification
---@param title string
---@param body string
---@param opts M.Opts?
function M.Send(title, body, opts)
  opts = opts or {}
  local cmd = "notify-send"

  if opts.timeout ~= nil then
    cmd = cmd .. " -t " .. opts.timeout
  end

  if opts.icon ~= nil then
    cmd = cmd .. " -i " .. opts.icon
  end

  if opts.transient ~= nil then
    cmd = cmd .. " -h boolean:transient:true"
    -- cmd = cmd .. " -e"
  end

  if opts.criticality ~= nil then
    cmd = cmd .. " -u " .. opts.criticality
  else
    cmd = cmd .. " -u normal"
  end

  cmd = table.concat({ cmd, string.format("%q", title), string.format("%q", body) }, " ")
  -- hl.notification.create({ text = cmd, timeout = opts.timeout or 1000, icon = 0, font_size = 17 })

  hl.exec_cmd(cmd)
end

return M
