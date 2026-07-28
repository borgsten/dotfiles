#!/usr/bin/env python3
"""
clamp_patch.py -- a generic matugen post_hook.

Run this on ANY rendered template file, for ANY app. It scans the text for
marker functions and replaces each one with a real, contrast-checked hex
color. Everything else in the file is left byte-for-byte untouched.

Each marker takes the color it's solving for FIRST, and the color it must
stay legible against LAST. This makes it work for both cases you'll run
into:

  - plain text on the terminal background:
      @clamp({{colors.primary.default.hex}}, {{colors.background.default.hex}})

  - a colored "pill" background that must stay legible under fixed text
    (e.g. Powerlevel10k Classic/Rainbow segments):
      @clamp({{colors.primary.default.hex}}, {{colors.on_background.default.hex}})

Markers:

    @clamp(HEX, REF)              HEX gets >= --normal-ratio contrast vs REF
    @clamp_bright(HEX, REF)       HEX gets >= --bright-ratio contrast vs REF
    @clamp_min(HEX, REF)          HEX gets only a SMALL separation from REF
                                   (use for things meant to sit close to REF,
                                   e.g. ANSI color 0 against the background)
    @clamp_hue(HEX, DEG, REF)     rotate HEX's hue by DEG, reset to neutral
                                   lightness/saturation, clamp vs REF at
                                   --normal-ratio. Use when you need a color
                                   matugen doesn't give you a role for
                                   (e.g. deriving green/yellow/cyan/magenta
                                   from a single primary/error seed).
    @clamp_hue_bright(HEX, DEG, REF)   same, --bright-ratio.

REF is just another hex value -- usually a matugen keyword like
{{colors.background.default.hex}} or {{colors.on_background.default.hex}},
but it can be any literal hex too (e.g. a hardcoded #000000).

Usage (as a matugen post_hook):

    post_hook = "python3 ~/.config/matugen/clamp_patch.py ~/.config/ghostty/matugen-theme.conf"

No --bg flag anymore -- every marker carries its own reference, so one
script invocation can patch a file that mixes both kinds of contrast
checks (e.g. a p10k file with plain text AND pill backgrounds).
"""

import argparse
import colorsys
import re

# --------------------------------------------------------------------------
# Color math
# --------------------------------------------------------------------------


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "".join(f"{max(0, min(255, round(c * 255))):02x}" for c in rgb)


def _linear(c):
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def relative_luminance(rgb):
    r, g, b = rgb
    return 0.2126 * _linear(r) + 0.7152 * _linear(g) + 0.0722 * _linear(b)


def contrast_ratio(rgb_a, rgb_b):
    la, lb = relative_luminance(rgb_a), relative_luminance(rgb_b)
    lighter, darker = max(la, lb), min(la, lb)
    return (lighter + 0.05) / (darker + 0.05)


def clamp_lightness(h, l, s, ref_rgb, min_ratio, walk_up, max_steps=200):
    """Walk lightness (hue/sat fixed) toward `walk_up` direction until the
    contrast ratio target against ref_rgb is met."""
    step = (1.0 if walk_up else -1.0) / max_steps
    best = colorsys.hls_to_rgb(h, l, s)
    for _ in range(max_steps):
        candidate = colorsys.hls_to_rgb(h, max(0.0, min(1.0, l)), s)
        best = candidate
        if contrast_ratio(candidate, ref_rgb) >= min_ratio:
            break
        l += step
        if l <= 0.0 or l >= 1.0:
            break
    return best


def direction_for(ref_rgb):
    """Walk away from the reference color's own lightness: darker text if
    the reference is light, lighter text if the reference is dark."""
    ref_l = colorsys.rgb_to_hls(*ref_rgb)[1]
    return ref_l <= 0.5  # True means increase lightness


# --------------------------------------------------------------------------
# Marker resolution
# --------------------------------------------------------------------------

HEX = r"#?([0-9a-fA-F]{6})"
MARKER_RE = re.compile(
    rf"@clamp_hue_bright\(\s*{HEX}\s*,\s*(-?\d+)\s*,\s*{HEX}\s*\)"
    rf"|@clamp_hue\(\s*{HEX}\s*,\s*(-?\d+)\s*,\s*{HEX}\s*\)"
    rf"|@clamp_bright\(\s*{HEX}\s*,\s*{HEX}\s*\)"
    rf"|@clamp_min\(\s*{HEX}\s*,\s*{HEX}\s*\)"
    rf"|@clamp\(\s*{HEX}\s*,\s*{HEX}\s*\)"
)


def make_resolver(normal_ratio, bright_ratio, min_ratio, sat_bounds):
    def resolve(match):
        (
            hb_hex,
            hb_deg,
            hb_ref,
            h_hex,
            h_deg,
            h_ref,
            br_hex,
            br_ref,
            mn_hex,
            mn_ref,
            pl_hex,
            pl_ref,
        ) = match.groups()

        if hb_hex is not None:
            r, g_, b = hex_to_rgb(hb_hex)
            h, l, s = colorsys.rgb_to_hls(r, g_, b)
            h = (h + float(hb_deg) / 360.0) % 1.0
            s = max(sat_bounds[0], min(s, sat_bounds[1]))
            ref_rgb = hex_to_rgb(hb_ref)
            rgb = clamp_lightness(
                h, 0.5, s, ref_rgb, bright_ratio, direction_for(ref_rgb)
            )

        elif h_hex is not None:
            r, g_, b = hex_to_rgb(h_hex)
            h, l, s = colorsys.rgb_to_hls(r, g_, b)
            h = (h + float(h_deg) / 360.0) % 1.0
            s = max(sat_bounds[0], min(s, sat_bounds[1]))
            ref_rgb = hex_to_rgb(h_ref)
            rgb = clamp_lightness(
                h, 0.5, s, ref_rgb, normal_ratio, direction_for(ref_rgb)
            )

        elif br_hex is not None:
            r, g_, b = hex_to_rgb(br_hex)
            h, l, s = colorsys.rgb_to_hls(r, g_, b)
            ref_rgb = hex_to_rgb(br_ref)
            rgb = clamp_lightness(
                h, l, s, ref_rgb, bright_ratio, direction_for(ref_rgb)
            )

        elif mn_hex is not None:
            r, g_, b = hex_to_rgb(mn_hex)
            h, l, s = colorsys.rgb_to_hls(r, g_, b)
            # HSL over-reports saturation near L=0/1 (a near-white or
            # near-black color can show S > 0.6 despite looking neutral).
            # @clamp_min is meant for subtle, near-background colors, so
            # cap saturation low regardless of what HSL claims here.
            s = min(s, 0.20)
            ref_rgb = hex_to_rgb(mn_ref)
            rgb = clamp_lightness(h, l, s, ref_rgb, min_ratio, direction_for(ref_rgb))

        else:
            r, g_, b = hex_to_rgb(pl_hex)
            h, l, s = colorsys.rgb_to_hls(r, g_, b)
            ref_rgb = hex_to_rgb(pl_ref)
            rgb = clamp_lightness(
                h, l, s, ref_rgb, normal_ratio, direction_for(ref_rgb)
            )

        return rgb_to_hex(rgb)

    return resolve


def main():
    ap = argparse.ArgumentParser(
        description="Generic contrast-clamping matugen post_hook."
    )
    ap.add_argument("--normal-ratio", type=float, default=4.5)
    ap.add_argument("--bright-ratio", type=float, default=7.0)
    ap.add_argument("--min-ratio", type=float, default=1.15)
    ap.add_argument("--sat-min", type=float, default=0.35)
    ap.add_argument("--sat-max", type=float, default=0.75)
    ap.add_argument("files", nargs="+")
    args = ap.parse_args()

    resolve = make_resolver(
        args.normal_ratio,
        args.bright_ratio,
        args.min_ratio,
        (args.sat_min, args.sat_max),
    )

    for path in args.files:
        with open(path) as f:
            text = f.read()
        patched, count = MARKER_RE.subn(resolve, text)
        with open(path, "w") as f:
            f.write(patched)
        print(f"[clamp_patch] {path}: {count} color(s) clamped")


if __name__ == "__main__":
    main()
