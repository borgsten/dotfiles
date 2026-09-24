-- Kanagawa, recoloured from the noctalia/matugen palette. Three variants, each
-- its own colorscheme (colors/kanagawa-*.lua), differing only in how syntax
-- colours are derived; plain `:colorscheme kanagawa` stays stock:
--   kanagawa-generated   functions/keywords/parameters/punctuation take the hue
--                        of primary/tertiary/secondary (weighted by how
--                        saturated they are, and not where that lands next to
--                        strings); everything else as in harmonized
--   kanagawa-harmonized  every syntax colour is kanagawa's, with its hue pulled
--                        at most MAX_HUE_SHIFT toward primary. Stays close to
--                        stock kanagawa's spacing between colours on any palette
--   kanagawa-rotated     all syntax hues are rotated together so functions land
--                        on primary's hue (weighted by its saturation). Keeps
--                        stock spacing exactly, but strings etc. change colour
--
-- The palette is rendered by theming/.config/matugen/templates/neovim.lua into
-- ~/.cache/theming/neovim.lua. When that file doesn't exist (a server, first
-- launch before noctalia has run) every variant is just stock kanagawa.
--
-- Kanagawa splits colours into a palette (sumiInk3, springGreen, ...) and a
-- theme mapping those onto roles (bg, string, keyword, ...). All variants share:
--   * neutrals (backgrounds, text, comments, borders) straight from the
--     generated surface roles, so nvim matches the terminal background
--   * selection/search/popup backgrounds from primary
--   * diagnostics, git and diff colours from kanagawa, harmonized toward
--     primary, so red still means error
-- Generated palettes don't have enough distinct hues to drive syntax on their
-- own -- noctalia's ANSI colours are just primary/secondary/tertiary again.
local M = {}

-- colorscheme name -> syntax variant
local VARIANTS = {
  ['kanagawa-generated'] = 'accents',
  ['kanagawa-harmonized'] = 'harmonized',
  ['kanagawa-rotated'] = 'rotated',
}
local DEFAULT = 'kanagawa-harmonized'

local PATH = vim.fs.joinpath(vim.env.XDG_CACHE_HOME or vim.fs.joinpath(vim.env.HOME, '.cache'), 'theming', 'neovim.lua')

-- How far (degrees) kanagawa's hues may be pulled toward primary. Material uses 15.
local MAX_HUE_SHIFT = math.rad(15)

-- Below this OKLCH chroma a colour is effectively grey and its hue meaningless.
local MIN_CHROMA = 0.02

-- From this chroma on an accent's hue is taken over completely; greyer accents
-- only pull partway, since their hue says little.
local FULL_CHROMA = 0.08

-- Accent-derived syntax colours keep at least this hue distance from strings
-- (and functions from keywords), or they'd be hard to tell apart.
local MIN_SEPARATION = math.rad(45)

-- Colour helpers --------------------------------------------------------------

local function hex_to_rgb(hex)
  return tonumber(hex:sub(2, 3), 16) / 255, tonumber(hex:sub(4, 5), 16) / 255, tonumber(hex:sub(6, 7), 16) / 255
end

local function rgb_to_hex(r, g, b)
  local function byte(c)
    return math.floor(math.min(math.max(c, 0), 1) * 255 + 0.5)
  end
  return string.format('#%02x%02x%02x', byte(r), byte(g), byte(b))
end

local function to_linear(c)
  return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

local function from_linear(c)
  return c <= 0.0031308 and c * 12.92 or 1.055 * c ^ (1 / 2.4) - 0.055
end

local function cbrt(x)
  return x < 0 and -((-x) ^ (1 / 3)) or x ^ (1 / 3)
end

-- https://bottosson.github.io/posts/oklab/
local function hex_to_oklch(hex)
  local r, g, b = hex_to_rgb(hex)
  r, g, b = to_linear(r), to_linear(g), to_linear(b)
  local l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
  local m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
  local s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
  local L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
  local A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
  local B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
  return L, math.sqrt(A * A + B * B), math.atan2(B, A)
end

local function oklch_to_rgb(L, C, h)
  local A, B = C * math.cos(h), C * math.sin(h)
  local l = (L + 0.3963377774 * A + 0.2158037573 * B) ^ 3
  local m = (L - 0.1055613458 * A - 0.0638541728 * B) ^ 3
  local s = (L - 0.0894841775 * A - 1.2914855480 * B) ^ 3
  return from_linear(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
    from_linear(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
    from_linear(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)
end

local function oklch_to_hex(L, C, h)
  -- rotating a hue can leave sRGB; back chroma off until it fits
  for _ = 1, 30 do
    local r, g, b = oklch_to_rgb(L, C, h)
    local eps = 1e-4
    if r >= -eps and r <= 1 + eps and g >= -eps and g <= 1 + eps and b >= -eps and b <= 1 + eps then
      return rgb_to_hex(r, g, b)
    end
    C = C * 0.95
  end
  return rgb_to_hex(oklch_to_rgb(L, C, h))
end

-- fg over bg at the given opacity
local function blend(fg, bg, alpha)
  local r1, g1, b1 = hex_to_rgb(fg)
  local r2, g2, b2 = hex_to_rgb(bg)
  return rgb_to_hex(r1 * alpha + r2 * (1 - alpha), g1 * alpha + g2 * (1 - alpha), b1 * alpha + b2 * (1 - alpha))
end

-- Pull hex's hue toward target's by half the difference, at most MAX_HUE_SHIFT.
local function harmonize(hex, target)
  local L, C, h = hex_to_oklch(hex)
  local _, tc, th = hex_to_oklch(target)
  if C < MIN_CHROMA or tc < MIN_CHROMA then
    return hex
  end
  local diff = (th - h + math.pi) % (2 * math.pi) - math.pi
  local shift = math.min(math.abs(diff) / 2, MAX_HUE_SHIFT)
  return oklch_to_hex(L, C, h + (diff < 0 and -shift or shift))
end

local function hue_distance(a, b)
  return math.abs((a - b + math.pi) % (2 * math.pi) - math.pi)
end

-- hex's lightness and chroma with source's hue, weighted by how saturated
-- source is. Where that lands within MIN_SEPARATION of a colour in avoid, keep
-- kanagawa's own hue instead, only harmonized toward primary: kanagawa's hues
-- are already far apart.
local function accent(hex, source, primary, avoid)
  local L, C, h = hex_to_oklch(hex)
  local _, sc, sh = hex_to_oklch(source)
  local weight = math.min(math.max((sc - MIN_CHROMA) / (FULL_CHROMA - MIN_CHROMA), 0), 1)
  local hue = h + ((sh - h + math.pi) % (2 * math.pi) - math.pi) * weight
  for _, other in ipairs(avoid) do
    local _, oc, oh = hex_to_oklch(other)
    if oc >= MIN_CHROMA and hue_distance(hue, oh) < MIN_SEPARATION then
      return harmonize(hex, primary)
    end
  end
  return oklch_to_hex(L, C, hue)
end

-- Hue rotation that puts from's hue onto to's, scaled by to's saturation.
local function rotation(from, to)
  local _, _, h = hex_to_oklch(from)
  local _, tc, th = hex_to_oklch(to)
  local weight = math.min(math.max((tc - MIN_CHROMA) / (FULL_CHROMA - MIN_CHROMA), 0), 1)
  return ((th - h + math.pi) % (2 * math.pi) - math.pi) * weight
end

local function rotate(hex, angle)
  local L, C, h = hex_to_oklch(hex)
  if C < MIN_CHROMA then
    return hex
  end
  return oklch_to_hex(L, C, h + angle)
end

local function is_light(hex)
  return (hex_to_oklch(hex)) > 0.6
end

-- Palette mapping ---------------------------------------------------------------

-- c: the generated roles; k: stock kanagawa palette; p: harmonized kanagawa
-- palette, which the functions below overwrite.

-- Palette colours kanagawa's theme uses for syntax, per theme; what
-- kanagawa-rotated rotates. `anchor` is the function colour.
local SYNTAX = {
  wave = {
    anchor = 'crystalBlue',
    'springGreen',
    'sakuraPink',
    'surimiOrange',
    'carpYellow',
    'oniViolet2',
    'crystalBlue',
    'oniViolet',
    'boatYellow2',
    'waveRed',
    'waveAqua2',
    'springViolet2',
    'springBlue',
    'peachRed',
  },
  lotus = {
    anchor = 'lotusBlue4',
    'lotusGreen',
    'lotusPink',
    'lotusOrange',
    'lotusYellow',
    'lotusBlue5',
    'lotusBlue4',
    'lotusViolet4',
    'lotusYellow2',
    'lotusRed',
    'lotusAqua',
    'lotusTeal1',
    'lotusTeal2',
  },
}

-- wave: kanagawa's dark theme
local function wave(c, p)
  local bg = c.background

  p.sumiInk0 = c.surface_container_lowest
  p.sumiInk1 = blend(bg, c.surface_container_lowest, 0.5)
  p.sumiInk2 = blend(bg, c.surface_container_lowest, 0.75)
  p.sumiInk3 = bg
  p.sumiInk4 = c.surface_container
  p.sumiInk5 = c.surface_container_high
  p.sumiInk6 = c.outline_variant

  p.fujiWhite = c.on_surface
  p.oldWhite = c.on_surface_variant
  p.fujiGray = c.outline
  p.katanaGray = c.outline

  -- selection, search, popup menus
  p.waveBlue1 = blend(c.primary, bg, 0.2)
  p.waveBlue2 = blend(c.primary, bg, 0.35)

  -- diff backgrounds: the (harmonized) git colours faded into the background
  p.winterGreen = blend(p.autumnGreen, bg, 0.2)
  p.winterYellow = blend(p.autumnYellow, bg, 0.2)
  p.winterRed = blend(p.autumnRed, bg, 0.2)
  p.winterBlue = blend(c.primary, bg, 0.12)
end

local function wave_accents(c, k, p)
  -- p still holds the harmonized kanagawa colours here, so functions also
  -- steer clear of the keyword colour's fallback
  local str = p.springGreen
  p.crystalBlue = accent(k.crystalBlue, c.primary, c.primary, { str, p.oniViolet }) -- functions
  p.oniViolet = accent(k.oniViolet, c.tertiary, c.primary, { str, p.crystalBlue }) -- keywords, statements
  p.oniViolet2 = accent(k.oniViolet2, c.tertiary, c.primary, { str }) -- parameters
  p.springViolet1 = accent(k.springViolet1, c.tertiary, c.primary, { str }) -- special ui
  p.springViolet2 = accent(k.springViolet2, c.secondary, c.primary, { str }) -- punctuation
end

-- lotus: kanagawa's light theme
local function lotus(c, p)
  local bg = c.background

  -- in light Material palettes the containers get darker, like lotusWhite0..2
  p.lotusWhite0 = c.surface_container_highest
  p.lotusWhite1 = c.surface_container_high
  p.lotusWhite2 = c.surface_container
  p.lotusWhite3 = bg
  p.lotusWhite4 = c.surface_container_low
  p.lotusWhite5 = c.surface_container

  p.lotusInk1 = c.on_surface
  p.lotusInk2 = c.on_surface_variant
  p.lotusGray = c.surface_container_highest
  p.lotusGray2 = c.outline
  p.lotusGray3 = c.outline
  p.lotusViolet1 = c.outline_variant

  p.lotusViolet3 = blend(c.primary, bg, 0.2)
  p.lotusBlue1 = blend(c.primary, bg, 0.1)
  p.lotusBlue2 = blend(c.primary, bg, 0.2)
  p.lotusBlue3 = blend(c.primary, bg, 0.3)

  p.lotusGreen3 = blend(p.lotusGreen2, bg, 0.25)
  p.lotusRed4 = blend(p.lotusRed2, bg, 0.25)
  p.lotusYellow4 = blend(p.lotusYellow3, bg, 0.3)
  p.lotusCyan = blend(c.primary, bg, 0.12)
end

local function lotus_accents(c, k, p)
  local str = p.lotusGreen
  p.lotusBlue4 = accent(k.lotusBlue4, c.primary, c.primary, { str, p.lotusViolet4 }) -- functions
  p.lotusViolet4 = accent(k.lotusViolet4, c.tertiary, c.primary, { str, p.lotusBlue4 }) -- keywords, statements
  p.lotusBlue5 = accent(k.lotusBlue5, c.tertiary, c.primary, { str }) -- parameters
  p.lotusViolet2 = accent(k.lotusViolet2, c.tertiary, c.primary, { str }) -- special ui
  p.lotusTeal1 = accent(k.lotusTeal1, c.secondary, c.primary, { str }) -- punctuation
end

-- kanagawa `colors` overrides ({ palette, theme }) for generated roles c.
---@param variant 'accents'|'harmonized'|'rotated'
function M.build(c, variant)
  local k = require('kanagawa.colors').setup({ theme = 'wave', colors = { palette = {}, theme = {} } }).palette
  local p = {}
  for name, hex in pairs(k) do
    p[name] = harmonize(hex, c.primary)
  end

  local theme = is_light(c.background) and 'lotus' or 'wave'
  if theme == 'lotus' then
    lotus(c, p)
  else
    wave(c, p)
  end

  if variant == 'accents' then
    if theme == 'lotus' then
      lotus_accents(c, k, p)
    else
      wave_accents(c, k, p)
    end
    return { palette = p }
  elseif variant == 'rotated' then
    -- rotate a copy and only use it for syntax: the palette colours are shared
    -- with diagnostics, git and terminal colours, which should keep meaning
    local names = SYNTAX[theme]
    local angle = rotation(k[names.anchor], c.primary)
    local r = vim.deepcopy(p)
    for _, name in ipairs(names) do
      r[name] = rotate(k[name], angle)
    end
    return { palette = p, theme = { all = { syn = require('kanagawa.themes')[theme](r).syn } } }
  end
  return { palette = p }
end

-- Loading -----------------------------------------------------------------------

local function read_colors()
  if not vim.uv.fs_stat(PATH) then
    return nil
  end
  local ok, colors = pcall(dofile, PATH)
  if not ok or type(colors) ~= 'table' then
    vim.notify('generated_theme: could not load ' .. PATH .. ':\n' .. tostring(colors), vim.log.levels.WARN)
    return nil
  end
  return colors
end

-- Body of colors/kanagawa-*.lua.
---@param name string colorscheme name, a key of VARIANTS
function M.load(name)
  local kanagawa = require('kanagawa')
  local colors = read_colors()

  if colors then
    local background = is_light(colors.background) and 'light' or 'dark'
    if vim.o.background ~= background then
      -- changing 'background' re-sources the current colorscheme, which may be
      -- this one; clear the name so it doesn't recurse
      vim.g.colors_name = nil
      vim.o.background = background
    end
  end

  -- Only borrow the colours for this load so `:colorscheme kanagawa` stays
  -- stock. Colour overrides from kanagawa.setup() still apply underneath.
  local user_colors = kanagawa.config.colors
  if colors then
    kanagawa.config.colors = vim.tbl_deep_extend('force', user_colors, M.build(colors, VARIANTS[name]))
  end
  local ok, err = pcall(kanagawa.load)
  kanagawa.config.colors = user_colors
  if not ok then
    error(err, 0)
  end

  vim.g.colors_name = name
end

-- noctalia rewrites the file on every theme change; watch the directory since
-- the file may be replaced rather than written in place.
local function watch()
  local dir = vim.fs.dirname(PATH)
  if not vim.uv.fs_stat(dir) then
    return
  end
  local timer = vim.uv.new_timer()
  local handle = vim.uv.new_fs_event()
  if not timer or not handle then
    return
  end
  handle:start(dir, {}, function(err, filename)
    if err or filename ~= vim.fs.basename(PATH) then
      return
    end
    timer:stop()
    timer:start(
      100,
      0,
      vim.schedule_wrap(function()
        if VARIANTS[vim.g.colors_name] then
          vim.cmd.colorscheme(vim.g.colors_name)
        end
      end)
    )
  end)
end

-- Configures kanagawa, starts watching the palette and switches to
-- kanagawa-harmonized.
---@param opts? table kanagawa.setup() options
function M.setup(opts)
  require('kanagawa').setup(opts)
  watch()
  vim.cmd.colorscheme(DEFAULT)
end

return M
