-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Dark mode (see runs/arch/07-dark-mode). The portal color-scheme signal does
-- most of the work; this forces GTK apps that read the env directly.
hl.env("GTK_THEME", "Adwaita:dark")

-- Qt: route every Qt5 and Qt6 app through Kvantum's dark theme. A single
-- style override works for both Qt versions (unlike QT_QPA_PLATFORMTHEME).
hl.env("QT_STYLE_OVERRIDE", "kvantum")
