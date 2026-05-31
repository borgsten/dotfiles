--------------------------------------------------------------------------------
---                                  INPUT                                   ---
--------------------------------------------------------------------------------

-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
  input = {
    kb_layout  = "se",
    kb_variant = "us",
    kb_model   = "",
    kb_options = "caps:super,compose:menu",
    kb_rules   = "",
    numlock_by_default = true,
    follow_mouse = 1,
    sensitivity = 0,
    special_fallthrough = true,
    touchpad = {
      natural_scroll = false,
    },
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures
hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})

-- Example per-device config
-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})
