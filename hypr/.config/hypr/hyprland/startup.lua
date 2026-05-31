--------------------------------------------------------------------------------
---                                AUTOSTART                                 ---
--------------------------------------------------------------------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("uwsm app -- scratch")
end)
