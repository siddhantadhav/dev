-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Internal laptop panel (Intel / i915)
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- External monitor (MSI MAG 275F — on the NVIDIA output).
-- Run it at its real refresh instead of 60.
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@180",
    position = "1920x0",
    scale    = 1,
})

-- Fallback for any other / unknown display
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- The actual fix for the external-monitor cursor flicker:
-- force software cursors (Lua form of the old cursor:no_hardware_cursors).
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})