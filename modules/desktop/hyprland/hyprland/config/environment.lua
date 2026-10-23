-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
local theme = dofile(os.getenv("HOME") .. "/.config/hypr/theme.lua")
local programs = require("programs")

-- the browser for Super+B and the rofi launcher's web searches (scripts/web)
hl.env("BROWSER", programs.browser)
hl.env("BROWSER_CLASS", programs.browserClass)

hl.env("XCURSOR_THEME", theme.cursor)
hl.env("HYPRCURSOR_THEME", theme.cursor)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- No GTK_THEME here: it would pin every GTK app to one theme and break
-- ./dev theme. GTK follows ~/.config/gtk-*/settings.ini + gsettings instead.

-- Qt: route every Qt5 and Qt6 app through Kvantum (theme set by ./dev theme).
-- A single style override works for both Qt versions (unlike QT_QPA_PLATFORMTHEME).
hl.env("QT_STYLE_OVERRIDE", "kvantum")
