# Rendered by matugen, then patched in place by clamp_patch.py (post_hook).
# Sourced from ~/.p10k.zsh -- see instructions below for wiring it in.

# ---- Plain text (Lean-style segments: no colored background) -----------
# Contrast-checked against the terminal background.
typeset -g P10K_DIR_FG='#@clamp_hue({{colors.primary.default.hex}}, 0, {{colors.background.default.hex}})'
typeset -g P10K_OK_FG='#@clamp_hue({{colors.primary.default.hex}}, 130, {{colors.background.default.hex}})'
typeset -g P10K_ERROR_FG='#@clamp_hue({{colors.error.default.hex}}, 0, {{colors.background.default.hex}})'
typeset -g P10K_VCS_CLEAN_FG='#@clamp_hue({{colors.primary.default.hex}}, 130, {{colors.background.default.hex}})'
typeset -g P10K_VCS_MODIFIED_FG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.background.default.hex}})'
typeset -g P10K_VCS_UNTRACKED_FG='#@clamp_hue_bright({{colors.primary.default.hex}}, 60, {{colors.background.default.hex}})'
typeset -g P10K_VCS_CONFLICTED_FG='#@clamp_hue({{colors.error.default.hex}}, 0, {{colors.background.default.hex}})'
typeset -g P10K_TIME_FG='#@clamp_hue({{colors.primary.default.hex}}, 180, {{colors.background.default.hex}})'
typeset -g P10K_CONTEXT_FG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.background.default.hex}})'
typeset -g P10K_VENV_FG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.background.default.hex}})'
typeset -g P10K_DIR_ANCHOR_FG='#@clamp({{colors.on_background.default.hex}}, {{colors.background.default.hex}})'

# Muted color for the git "loading/stale" state -- deliberately a lower
# contrast ratio (see --min-ratio on this template's post_hook) so it
# reads as de-emphasized rather than full-strength text.
typeset -g P10K_VCS_LOADING_FG='#@clamp_min({{colors.background.default.hex}}, {{colors.background.default.hex}})'

# ---- Colored "pill" segments (Classic/Rainbow-style: colored background,
# fixed text). All pills share the same text color, so it only needs to be
# solved once; every *_BG below is contrast-checked against THAT color,
# not the terminal background.
typeset -g P10K_PILL_FG='#{{colors.on_background.default.hex}}'

typeset -g P10K_DIR_BG='#@clamp_hue({{colors.primary.default.hex}}, 0, {{colors.on_background.default.hex}})'
typeset -g P10K_OK_BG='#@clamp_hue({{colors.primary.default.hex}}, 130, {{colors.on_background.default.hex}})'
typeset -g P10K_ERROR_BG='#@clamp_hue({{colors.error.default.hex}}, 0, {{colors.on_background.default.hex}})'
typeset -g P10K_VCS_CLEAN_BG='#@clamp_hue({{colors.primary.default.hex}}, 130, {{colors.on_background.default.hex}})'
typeset -g P10K_VCS_MODIFIED_BG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.on_background.default.hex}})'
typeset -g P10K_VCS_UNTRACKED_BG='#@clamp_hue_bright({{colors.primary.default.hex}}, 60, {{colors.on_background.default.hex}})'
typeset -g P10K_VCS_CONFLICTED_BG='#@clamp_hue({{colors.error.default.hex}}, 0, {{colors.on_background.default.hex}})'
typeset -g P10K_TIME_BG='#@clamp_hue({{colors.primary.default.hex}}, 180, {{colors.on_background.default.hex}})'
typeset -g P10K_CONTEXT_BG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.on_background.default.hex}})'
typeset -g P10K_VENV_BG='#@clamp_hue({{colors.primary.default.hex}}, 60, {{colors.on_background.default.hex}})'
