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
    -- Focus inside a group cycles its tabs before escaping to the neighbour.
    movefocus_cycles_groupfirst = true,
  },

  -- See https://wiki.hyprland.org/Configuring/Variables/#group for more
  group = {
    -- A window opened while a group is focused tiles beside it rather than
    -- silently becoming a tab; windows join only via SUPER + SHIFT + <dir>.
    auto_group = true,
  },
})
