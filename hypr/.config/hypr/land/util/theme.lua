--- Loads the Matugen-generated Material You palette from `~/.cache/theming`.
---@class Util.Theme
local M            = {}

local CACHE_MODULE = "hyprland_theme"
local CACHE_PATH   = os.getenv("HOME") .. "/.cache/theming"

local DEFAULTS     = {
  primary                 = "rgb(205,193,227)",
  onPrimary               = "rgb(52,44,71)",
  primaryContainer        = "rgb(62,54,81)",
  onPrimaryContainer      = "rgb(170,159,192)",
  primaryFixed            = "rgb(233,221,255)",
  primaryFixedDim         = "rgb(205,193,227)",
  onPrimaryFixed          = "rgb(31,23,48)",
  onPrimaryFixedVariant   = "rgb(75,66,94)",
  inversePrimary          = "rgb(99,90,119)",

  secondary               = "rgb(203,196,211)",
  onSecondary             = "rgb(50,47,58)",
  secondaryContainer      = "rgb(75,71,83)",
  onSecondaryContainer    = "rgb(188,182,196)",
  secondaryFixed          = "rgb(231,224,239)",
  secondaryFixedDim       = "rgb(203,196,211)",
  onSecondaryFixed        = "rgb(29,26,37)",
  onSecondaryFixedVariant = "rgb(73,69,81)",

  tertiary                = "rgb(232,186,202)",
  onTertiary              = "rgb(70,39,52)",
  tertiaryContainer       = "rgb(81,49,62)",
  onTertiaryContainer     = "rgb(196,153,168)",
  tertiaryFixed           = "rgb(255,217,229)",
  tertiaryFixedDim        = "rgb(232,186,202)",
  onTertiaryFixed         = "rgb(46,19,31)",
  onTertiaryFixedVariant  = "rgb(95,61,74)",

  error                   = "rgb(255,180,171)",
  onError                 = "rgb(105,0,5)",
  errorContainer          = "rgb(147,0,10)",
  onErrorContainer        = "rgb(255,218,214)",

  surface                 = "rgb(20,19,21)",
  onSurface               = "rgb(230,225,228)",
  surfaceVariant          = "rgb(73,69,77)",
  onSurfaceVariant        = "rgb(202,196,205)",
  surfaceDim              = "rgb(20,19,21)",
  surfaceBright           = "rgb(58,57,59)",
  surfaceTint             = "rgb(205,193,227)",
  surfaceContainerLowest  = "rgb(15,14,16)",
  surfaceContainerLow     = "rgb(28,27,29)",
  surfaceContainer        = "rgb(32,31,33)",
  surfaceContainerHigh    = "rgb(43,41,44)",
  surfaceContainerHighest = "rgb(54,52,54)",
  inverseSurface          = "rgb(230,225,228)",
  inverseOnSurface        = "rgb(49,48,50)",

  background              = "rgb(20,19,21)",
  onBackground            = "rgb(230,225,228)",

  outline                 = "rgb(148,143,151)",
  outlineVariant          = "rgb(73,69,77)",
  shadow                  = "rgb(0,0,0)",
  scrim                   = "rgb(0,0,0)",
}

---@type table?
local theme        = nil

---@param text string
local function warn(text)
  UTIL.notif.osd(text, { timeout = 15000 })
end

---@return table
local function load()
  package.path = CACHE_PATH .. "/?.lua;" .. package.path

  if not package.searchpath(CACHE_MODULE, package.path) then
    warn("Theme cache missing, using fallback colors -- regen the theme")
    return UTIL.tbl.copy(DEFAULTS)
  end

  local ok, mod = pcall(require, CACHE_MODULE)
  if not ok then
    warn("Theme cache broken, using fallback colors: " .. tostring(mod))
    return UTIL.tbl.copy(DEFAULTS)
  end
  if type(mod) ~= "table" then
    warn("Theme cache did not return a table, using fallback colors")
    return UTIL.tbl.copy(DEFAULTS)
  end

  local missing = {}
  for role in pairs(DEFAULTS) do
    if mod[role] == nil then missing[#missing + 1] = role end
  end
  if #missing > 0 then
    table.sort(missing)
    warn("Theme cache missing roles, regen needed: " .. table.concat(missing, ", "))
  end

  return UTIL.tbl.merge(DEFAULTS, mod)
end

---@return table
function M.get()
  if theme == nil then
    theme = load()
  end
  return theme
end

return M
