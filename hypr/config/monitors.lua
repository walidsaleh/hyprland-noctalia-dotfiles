-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly

hl.monitor({
    output    = "eDP-1",
    mode      = "1920x1200@60.0",
    position  = "0x660",
    scale     = "1.0",
    vrr       = 0,
})

hl.monitor({
    output    = "DP-3",
    mode      = "3840x2160@60.0",
    position  = "1920x0",
    scale     = "1",
    vrr       = 0,
})
