--------------------------------------------------------------------------------
---                          WINDOWS AND WORKSPACES                          ---
--------------------------------------------------------------------------------

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

hl.window_rule({
  name           = "suppress-maximize-events",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name     = "fix-xwayland-drags",
  match    = {
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
  name        = "no-gaps-wtv1",
  match       = { float = false, workspace = "w[tv1]" },
  border_size = 0,
  rounding    = 0,
})

hl.window_rule({
  name        = "no-gaps-f1",
  match       = { float = false, workspace = "f[1]" },
  border_size = 0,
  rounding    = 0,
})

-- Tag games
hl.window_rule({
  match = { class = "^(steam_app_\\d+)$" },
  tag   = "+games",
})

hl.window_rule({
  name    = "game-rules",
  match   = { tag = "games" },
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

-- Floating
hl.window_rule({ match = { title = "^(Open File)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, tag = "+dialog" })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, tag = "+dialog" })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, tag = "+dialog" })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, tag = "+dialog" })
hl.window_rule({ match = { class = "^(Zotero)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "^(guifetch)$" }, tag = "+dialog" }) -- FlafyDev/guifetch
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, tag = "+dialog" })
hl.window_rule({ match = { class = "kcm_.*" }, tag = "+dialog" })
hl.window_rule({ match = { title = ".*Shell conflicts.*" }, tag = "+dialog" })
hl.window_rule({ match = { title = ".*Welcome" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(.*)(wants to open)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(.*)(wants to save)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(Choose wallpaper)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(Library)(.*)$" }, tag = "+dialog" })
hl.window_rule({ match = { title = "^(illogical-impulse Settings)$" }, tag = "+dialog" })

hl.window_rule({
  name   = "dialog-rules",
  match  = { tag = "dialog" },
  float  = true,
  size   = { "monitor_w * 0.5", "monitor_h * 0.5" },
  center = true,
})
