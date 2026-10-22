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

-- Blur behind the translucent bar, launcher and notifications; ignore_alpha
-- keeps the blur to their painted panels (not the fully clear gaps).
hl.layer_rule({
    name  = "glass-panels",
    match = { namespace = "^(waybar|wofi|notifications)$" },

    blur         = true,
    ignore_alpha = 0.1,
})
