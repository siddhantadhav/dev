-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Glass exemptions. kitty does background-only transparency itself
-- (templates/kitty.conf); Hyprland opacity on top would also fade its text.
-- Photos and video should never be tinted by the wallpaper.
hl.window_rule({
    name  = "solid-kitty-and-media",
    match = { class = "^(kitty|mpv|imv|org\\.gnome\\.Loupe|vlc)$" },

    opacity = "1.0 override",
})

hl.window_rule({
    name  = "solid-picture-in-picture",
    match = { title = "^Picture-in-Picture$" },

    opacity = "1.0 override",
})

-- Blur behind the translucent bar, launcher (rofi) and notifications; ignore_alpha
-- keeps the blur to their painted panels (not the fully clear gaps).
hl.layer_rule({
    name  = "glass-panels",
    match = { namespace = "^(waybar|rofi|notifications)$" },

    blur         = true,
    ignore_alpha = 0.1,
})

-- Waybar click popups (configs/hyprland/waybar/scripts/popup): floating kitty
-- windows centred on screen. Calendar and weather are sized to their output
-- at kitty's font size (calendar ≈ 68 columns, weather ≈ 104) so nothing wraps.
hl.window_rule({
    name  = "waybar-popups",
    match = { class = "^waybar-popup-.*$" },

    float  = true,
    size   = "1100 680",
    center = true,
})

hl.window_rule({
    name  = "waybar-popup-calendar",
    match = { class = "^waybar-popup-calendar$" },

    size = "820 330",
})

hl.window_rule({
    name  = "waybar-popup-weather",
    match = { class = "^waybar-popup-weather$" },

    size = "1240 580",
})

hl.window_rule({
    name  = "waybar-popup-sysinfo",
    match = { class = "^waybar-popup-sysinfo$" },

    size = "1120 400",
})

hl.window_rule({
    name  = "waybar-popup-media",
    match = { class = "^waybar-popup-media$" },

    size = "900 400",
})

-- bluetui (Bluetooth settings): device lists + pairing prompts need room
hl.window_rule({
    name  = "waybar-popup-bluetooth",
    match = { class = "^waybar-popup-bluetooth$" },

    size = "1000 600",
})
