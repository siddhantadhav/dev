-- Colours + cursor of the current ~/dev theme, rendered by ./dev theme.
-- dofile'd (not require'd) so `hyprctl reload` always rereads it; falls back
-- to neutral values so Hyprland still starts before the first ./dev theme.
local ok, theme = pcall(dofile, os.getenv("HOME") .. "/.config/dev/theme/hypr.lua")
if ok then return theme end
return {
    active_border   = "rgb(888888)",
    inactive_border = "rgb(444444)",
    shadow          = 0x661a1a1a,
    shadow_inactive = 0x331a1a1a,
    cursor          = "Adwaita",
    active_opacity  = 1.0,
    inactive_opacity = 1.0,
}
