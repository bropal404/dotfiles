-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- MODERN BLURRY HYPRLAND LUA CONFIGURATION                             --
-- With Quickshell (M3 Bar, Control Center, Notifications),             --
-- Hyperbolic Plugin, Multi-Monitor Stack, and Frosted Glass Aesthetics  --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))
hl.env("LD_LIBRARY_PATH", os.getenv("HOME") .. "/.local/lib:" .. (os.getenv("LD_LIBRARY_PATH") or ""))


------------------
---- MONITORS ----
------------------

-- Primary/Internal Laptop Display (eDP-1 placed at bottom/auto)
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- External monitor positioned on TOP of laptop screen
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "auto-up",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-1",
    mode     = "preferred",
    position = "auto-up",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-2",
    mode     = "preferred",
    position = "auto-up",
    scale    = "auto",
})

-- Generic fallback for any other external display (always placed on top)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto-up",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal      = "kitty"
local fileManager   = "dolphin"
local menu          = "qs ipc call startmenu toggle"          -- Quickshell Launcher
local controlCenter = "qs ipc call controlcenter toggle"      -- Quickshell Control Center
local search        = "/home/gopal/.config/rofi/launch find" -- rofi: apps / run / windows / files
local exitMenu      = "wlogout -b 5 -c 8 -r 8"
local lockScreen    = "hyprlock"                              -- Modern Blur Lockscreen


--------------------
---- PLUGINS ------
--------------------

-- Load the Hyperbolic plugin for dynamic window resizing as they move
hl.plugin.load(os.getenv("HOME") .. "/.local/lib/hyprland-plugins/hyperbolic.so")

-- Configure Hyperbolic
hl.config({
    plugin = {
        hyperbolic = {
            enabled            = true,
            ["function"]       = "rational", -- rational | gaussian | hyperbola
            alpha              = 2.0,
            base_width         = 0.50,
            base_height        = 0.80,
            min_scale          = 0.08,
            animation_speed    = 12.0,
            visual_scale_ratio = 0.5,        -- 0.0 = buffer resize only, 1.0 = visual scale only, 0.5 = 50/50 blend
            min_visual_scale   = 0.20,
        },
    },
})


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    -- Unlock KWallet with the login password (needs pam_kwallet5 in /etc/pam.d/greetd)
    hl.exec_cmd("/usr/lib/pam_kwallet_init")

    -- Wallpaper daemon (Colorful Modern Art Wallpaper)
    hl.exec_cmd("hyprpaper")

    -- Quickshell modern blurry shell (~/.config/quickshell)
    hl.exec_cmd("qs")

    -- Terminal on startup
    hl.exec_cmd(terminal)
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        -- Gradient border matching modern art wallpaper & quickshell theme
        col = {
            active_border   = { colors = { "rgba(c9beffee)", "rgba(ff7b00ee)", "rgba(4cc9f0ee)" }, angle = 45 },
            inactive_border = "rgba(201f25aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2,

        -- Frosted glassy transparency
        active_opacity   = 0.94,
        inactive_opacity = 0.85,
        dim_inactive     = true,
        dim_strength     = 0.08,

        -- Deep diffused modern drop shadow
        shadow = {
            enabled        = true,
            range          = 22,
            render_power   = 4,
            offset         = { 0, 4 },
            color          = "rgba(00000055)",
            color_inactive = "rgba(00000025)",
        },

        -- Creamy multi-pass Gaussian blur
        blur = {
            enabled           = true,
            size              = 8,
            passes            = 3,
            vibrancy          = 0.25,
            vibrancy_darkness = 0.10,
            noise             = 0.015,
            contrast          = 0.92,
            brightness        = 0.88,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Fluid modern curves (quintic ease out, cubic, overshot springs)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("overshot",       { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,  bezier = "easeOutQuint" })
hl.animation({ leaf = "border",        enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.5, bezier = "overshot" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.5, bezier = "overshot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4.5, bezier = "overshot" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "easeInOutCubic" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "linear" })
hl.animation({ leaf = "layers",        enabled = true, speed = 4,   bezier = "overshot", style = "slide" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,   bezier = "overshot", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.5, bezier = "easeOutQuint", style = "slide" })

hl.config({
    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = 0x141318,
    },
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- 3-finger horizontal swipe: switch workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace"
})

-- 4-finger swipe up / down: send the current workspace to the monitor above / below
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function() hl.dispatch(hl.dsp.workspace.move({ monitor = "u" })) end,
})
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function() hl.dispatch(hl.dsp.workspace.move({ monitor = "d" })) end,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Core Application Binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Hyperbolic Plugin Floating Window Toggle (Preserved & Enhanced)
hl.bind(mainMod .. " + SPACE", function()
    if not hl.plugin.hyperbolic.is_enabled() then
        hl.plugin.hyperbolic.enable()
    end
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end)

-- Launcher & Control Center
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + Super_L", hl.dsp.exec_cmd(menu), { release = true })
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(controlCenter))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(controlCenter))

-- Search Finder, Lockscreen & Power Menu
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(search))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockScreen))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(exitMenu))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(exitMenu))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())

-- Focus Navigation (Arrow keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Window Swapping (Super + Ctrl + Arrows)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.swap({ direction = "d" }))

----------------------------------------------------
-- MULTI-MONITOR & WORKSPACE MANAGEMENT KEYBINDINGS --
----------------------------------------------------

-- Focus monitor above / below (External monitor is on top!)
hl.bind(mainMod .. " + ALT + up",    hl.dsp.focus({ monitor = "u" }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.focus({ monitor = "d" }))
hl.bind(mainMod .. " + ALT + TAB",   hl.dsp.focus({ monitor = "+1" }))

-- Move Active Window to Monitor Above (External) / Below (Laptop)
hl.bind(mainMod .. " + SHIFT + CTRL + up",   hl.dsp.window.move({ monitor = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d" }))

-- Move Entire Active Workspace to Monitor Above / Below / Next
hl.bind(mainMod .. " + SHIFT + up",   hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.workspace.move({ monitor = "d" }))
hl.bind(mainMod .. " + SHIFT + M",    hl.dsp.workspace.move({ monitor = "+1" }))

-- Swap Active Workspaces Between Both Monitors
hl.bind(mainMod .. " + ALT + S", function()
    local mons = hl.get_monitors()
    if #mons >= 2 then
        hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = mons[1].name, monitor2 = mons[2].name }))
    end
end)

-- Workspace Switching (Super + 1-10) and Move Window to Workspace (Super + Shift + 1-10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Scratchpad Workspace
hl.bind(mainMod .. " + grave",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse Wheel Workspace Scrolling
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Window Drag & Resize with Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop Multimedia & Audio Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                          { locked = true, repeating = true })

-- Media Player Keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


----------------------------------
---- BLURRY SHELL LAYER RULES ----
----------------------------------

-- Quickshell UI frosted blur layer rules
hl.layer_rule({ name = "qs-bar-blur",            match = { namespace = "^qs-bar$" },            blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "qs-launcher-blur",       match = { namespace = "^qs-launcher$" },       blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "qs-control-center-blur", match = { namespace = "^qs-control-center$" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "qs-notifications-blur",  match = { namespace = "^qs-notifications$" },  blur = true, ignore_alpha = 0 })

-- App Finder & Power Dialog blur
hl.layer_rule({ name = "rofi-blur",              match = { namespace = "^rofi$" },              blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "wofi-blur",              match = { namespace = "^wofi$" },              blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "wlogout-blur",           match = { namespace = "^wlogout$" },           blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "notifs-blur",            match = { namespace = "^notifications$" },      blur = true, ignore_alpha = 0 })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Glassy Translucency for Core Applications
hl.window_rule({
    name  = "kitty-opacity",
    match = { class = "^(kitty|Alacritty)$" },
    opacity = 0.88,
})

hl.window_rule({
    name  = "dolphin-opacity",
    match = { class = "^(org.kde.dolphin|dolphin)$" },
    opacity = 0.90,
})

-- Suppress maximize requests
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging
hl.window_rule({
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

-- Pavucontrol Floating
hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "pavucontrol|org.pulseaudio.pavucontrol" },
    float = true,
    size  = "720 520",
})
