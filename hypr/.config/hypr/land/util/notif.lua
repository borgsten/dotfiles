---@class Util.Notif
local M = {}

---@alias Util.Notif.Crit "low" | "normal" | "critical"

---@class Util.Notif.Opts
---@field timeout? integer
---@field icon? string
---@field transient? boolean
---@field criticality? Util.Notif.Crit

--- Desktop notification, for anything seen during a normal session.
---@param title string
---@param body string
---@param opts Util.Notif.Opts?
function M.send(title, body, opts)
  opts = opts or {}
  local cmd = "notify-send"

  if opts.timeout ~= nil then
    cmd = cmd .. " -t " .. opts.timeout
  end

  if opts.icon ~= nil then
    cmd = cmd .. " -i " .. opts.icon
  end

  if opts.transient == true then
    cmd = cmd .. " -h boolean:transient:true"
  end

  cmd = cmd .. " -u " .. (opts.criticality or "normal")
  cmd = table.concat({ cmd, string.format("%q", title), string.format("%q", body) }, " ")

  hl.exec_cmd(cmd)
end

--- Hyprland's own overlay. For problems raised while the config is being
--- evaluated, when a notify-send would go nowhere.
---@param text string
---@param opts {timeout?: integer, icon?: integer, font_size?: number}?
function M.osd(text, opts)
  opts = opts or {}
  hl.notification.create({
    text = text,
    timeout = opts.timeout or 10000,
    icon = opts.icon or 0,
    font_size = opts.font_size or 17,
  })
end

return M
