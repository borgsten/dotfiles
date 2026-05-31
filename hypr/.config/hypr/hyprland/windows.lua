--------------------------------------------------------------------------------
---                          WINDOWS AND WORKSPACES                          ---
--------------------------------------------------------------------------------

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

-- Scratch
hl.window_rule({
  name      = "scratchpad",
  match     = { class = "com.scratch" },
  float     = true,
  workspace = "special:scratch",
  size      = "80% 80%",
})

hl.window_rule({
  name  = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

-- Emulate Smart Gaps
hl.window_rule({
  name  = "no-gaps-wtv1",
  match = { float = false, workspace = "w[tv1]" },
  border_size = 0,
  rounding    = 0,
})

hl.window_rule({
  name  = "no-gaps-f1",
  match = { float = false, workspace = "f[1]" },
  border_size = 0,
  rounding    = 0,
})

-- Tag games
hl.window_rule({
  match = { class = "^(steam_app_\\d+)$" },
  tag   = "+games",
})

hl.window_rule({
  name  = "game-rules",
  match = { tag = "games" },
  size    = ">20 >20",
  no_blur = true,
  no_anim = true,
  center  = true,
})

hl.window_rule({
  match            = { class = "FreeCAD" },
  no_initial_focus = true,
})

hl.window_rule({
  match            = { class = "^(steam)$", title = "^(notificationtoasts)" },
  no_initial_focus = true,
})
hl.window_rule({
  match = { class = "^(steam)$", title = "^(notificationtoasts)" },
  pin   = true,
})
