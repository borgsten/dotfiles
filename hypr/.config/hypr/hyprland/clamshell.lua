--------------------------------------------------------------------------------
---                                CLAMSHELL                                 ---
--------------------------------------------------------------------------------

local clamshell = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
  .. "/hypr/hyprland/scripts/clamshell.sh"

hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd(clamshell .. " close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(clamshell .. " open"),  { locked = true })

-- Re-evaluate lid state on Hyprland start/reload
local function check_clamshell()
  hl.exec_cmd(clamshell .. " check")
end
hl.on("hyprland.start",    check_clamshell)
hl.on("config.reloaded",   check_clamshell)
