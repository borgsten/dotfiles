-- Kanagawa, recoloured from the noctalia/matugen palette, available as the
-- `kanagawa-generated` colorscheme (colors/kanagawa-generated.lua). Plain
-- `:colorscheme kanagawa` stays stock.
--
-- The palette is rendered by theming/.config/matugen/templates/neovim.lua into
-- ~/.cache/theming/neovim.lua. When that file doesn't exist (a server, first
-- launch before noctalia has run) kanagawa-generated is just stock kanagawa.
--
-- Kanagawa splits colours into a palette (sumiInk3, springGreen, ...) and a
-- theme mapping those onto roles (bg, string, keyword, ...). Only the palette
-- is replaced, so kanagawa's role mapping and highlight groups stay intact:
--   * neutrals (backgrounds, text, comments, borders) come straight from the
--     generated surface roles, so nvim matches the terminal background
--   * functions/keywords take the hue of primary/tertiary, keeping
--     kanagawa's lightness and chroma
--   * everything else (strings green, errors red, ...) keeps its kanagawa
--     colour with the hue nudged toward primary, like Material's custom colour
--     harmonization. Generated palettes don't have enough distinct hues to
--     drive syntax on their own -- noctalia's ANSI colours are just
--     primary/secondary/tertiary again.
local M = {}

local NAME = 'kanagawa-generated'

local PATH = vim.fs.joinpath(vim.env.XDG_CACHE_HOME or vim.fs.joinpath(vim.env.HOME, '.cache'), 'theming', 'neovim.lua')

-- How far (degrees) kanagawa's hues may be pulled toward primary. Material uses 15.
local MAX_HUE_SHIFT = math.rad(15)

-- Below this OKLCH chroma a colour is effectively grey and its hue meaningless.
local MIN_CHROMA = 0.02

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

-- hex's lightness and chroma with source's hue.
local function rehue(hex, source)
  local L, C = hex_to_oklch(hex)
  local _, sc, sh = hex_to_oklch(source)
  if sc < MIN_CHROMA then
    return harmonize(hex, source)
  end
  return oklch_to_hex(L, C, sh)
end

local function is_light(hex)
  return (hex_to_oklch(hex)) > 0.6
end

-- Palette mapping ---------------------------------------------------------------

-- c: the generated roles; k: stock kanagawa palette; p: harmonized kanagawa
-- palette, which the functions below overwrite for neutrals and accents.

-- wave: kanagawa's dark theme
local function wave(c, k, p)
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

  p.crystalBlue = rehue(k.crystalBlue, c.primary)       -- functions
  p.oniViolet = rehue(k.oniViolet, c.tertiary)          -- keywords, statements
  p.oniViolet2 = rehue(k.oniViolet2, c.tertiary)        -- parameters
  p.springViolet1 = rehue(k.springViolet1, c.tertiary)  -- special ui
  p.springViolet2 = rehue(k.springViolet2, c.secondary) -- punctuation
end

-- lotus: kanagawa's light theme
local function lotus(c, k, p)
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

  p.lotusBlue4 = rehue(k.lotusBlue4, c.primary)      -- functions
  p.lotusViolet4 = rehue(k.lotusViolet4, c.tertiary) -- keywords, statements
  p.lotusBlue5 = rehue(k.lotusBlue5, c.tertiary)     -- parameters
  p.lotusViolet2 = rehue(k.lotusViolet2, c.tertiary) -- special ui
  p.lotusTeal1 = rehue(k.lotusTeal1, c.secondary)    -- punctuation
end

function M.palette(c)
  local k = require('kanagawa.colors').setup({ theme = 'wave', colors = { palette = {}, theme = {} } }).palette
  local p = {}
  for name, hex in pairs(k) do
    p[name] = harmonize(hex, c.primary)
  end
  if is_light(c.background) then
    lotus(c, k, p)
  else
    wave(c, k, p)
  end
  return p
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

-- Body of colors/kanagawa-generated.lua.
function M.load()
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

  -- Only borrow the palette for this load so `:colorscheme kanagawa` stays
  -- stock. Palette overrides from kanagawa.setup() still apply underneath.
  local user_palette = kanagawa.config.colors.palette
  kanagawa.config.colors.palette = vim.tbl_extend('force', user_palette, colors and M.palette(colors) or {})
  local ok, err = pcall(kanagawa.load)
  kanagawa.config.colors.palette = user_palette
  if not ok then
    error(err, 0)
  end

  vim.g.colors_name = NAME
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
    timer:start(100, 0, vim.schedule_wrap(function()
      if vim.g.colors_name == NAME then
        vim.cmd.colorscheme(NAME)
      end
    end))
  end)
end

-- Configures kanagawa, starts watching the palette and switches to
-- kanagawa-generated.
---@param opts? table kanagawa.setup() options
function M.setup(opts)
  require('kanagawa').setup(opts)
  watch()
  vim.cmd.colorscheme(NAME)
end

return M
