--------------------------------------------------------------------------------
---                                  TILING                                  ---
--------------------------------------------------------------------------------

-- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },

  -- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
  master = {
    new_status = "master",
  },

  binds = {
    workspace_back_and_forth = true,
    -- Treat a group like an i3 tabbed container: moving focus inside one
    -- cycles its tabs before escaping to the neighbouring window.
    movefocus_cycles_groupfirst = true,
  },

  -- See https://wiki.hyprland.org/Configuring/Variables/#group for more
  group = {
    -- Groups are explicit containers, like i3. A window opened while a group
    -- is focused tiles beside it instead of silently becoming another tab;
    -- windows join a group only via SUPER + SHIFT + <dir>.
    auto_group = false,
  },
})
