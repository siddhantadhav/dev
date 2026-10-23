-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
local theme = dofile(os.getenv("HOME") .. "/.config/hypr/theme.lua")

hl.config({
    general = {
        -- waybar's margins (12) line up with gaps_out
        gaps_in  = 5,
        gaps_out = 12,

        border_size = 2,

        -- colours from the theme: gradient accent → blue on the focused window
        col = {
            active_border   = theme.active_border,
            inactive_border = theme.inactive_border,
        },

        -- drag a window's border or the gap next to it to resize
        resize_on_border        = true,
        extend_border_grab_area = 12,

        -- floating windows snap to each other and to the screen edges
        snap = {
            enabled      = true,
            window_gap   = 10,
            monitor_gap  = 12,
            respect_gaps = true,
        },

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- between a circle (2) and a squircle (4): softer, more modern corners
        rounding       = 12,
        rounding_power = 3,

        -- Glass: every window slightly see-through (~/dev/themes/_style.sh);
        -- fullscreen stays solid, kitty/media are exempt in window-rules.lua
        active_opacity     = theme.active_opacity,
        inactive_opacity   = theme.inactive_opacity,
        fullscreen_opacity = 1.0,

        -- wide, soft and dropped a little: depth without a dark halo
        shadow = {
            enabled        = true,
            range          = 20,
            render_power   = 3,
            offset         = { 0, 4 },
            color          = theme.shadow,
            color_inactive = theme.shadow_inactive,
        },

        -- heavy + dimmed so the wallpaper's neon reads as soft colour, not
        -- shapes, behind text
        blur = {
            enabled    = true,
            size       = 8,
            passes     = 3,
            brightness = 0.7,
            contrast   = 0.9,
            noise      = 0.02,
            vibrancy   = 0.17,
            popups     = true,
        },

        -- the rest of the screen dims behind the scratchpad (special workspace)
        dim_special = 0.3,
    },

    animations = {
        enabled = true,
    },
})

-- Animations: short and decelerating, so things land fast and settle softly.
-- speed is in tenths of a second. See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("snappy",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1}    } })  -- fast start, soft landing
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })  -- same, with a hint of bounce
hl.curve("linear",   { type = "bezier", points = { {0, 0},      {1, 1}      } })

hl.animation({ leaf = "global",           enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3.5, bezier = "overshot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 2.2, bezier = "snappy",   style = "popin 90%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "border",           enabled = true, speed = 4,   bezier = "snappy" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.5, bezier = "snappy" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 2.5, bezier = "snappy",   style = "fade" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.8, bezier = "snappy",   style = "fade" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3,   bezier = "snappy",   style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "snappy",   style = "slidefadevert 20%" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 3,   bezier = "snappy" })
