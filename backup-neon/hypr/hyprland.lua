-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- RETRO HYPRLAND LUA CONFIGURATION                     --
-- Complete with Multi-Monitor, Hyperbolic Plugin,      --
-- Waybar, Retro Theme, Wofi Launcher, Wlogout & HUD.    --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun"
local search      = "/home/gopal/.local/bin/retro-search"
local exitMenu    = "wlogout -b 2"
local lockScreen  = "hyprlock"
local retroHud    = "/home/gopal/.local/bin/retro-hud-toggle"


--------------------
---- PLUGINS ------
--------------------

-- Load the Hyperbolic plugin for dynamic window resizing as they move
hl.plugin.load(os.getenv("HOME") .. "/.local/lib/hyprland-plugins/hyperbolic.so")

-- Configure Hyperbolic
hl.config({
    plugin = {
        hyperbolic = {
            enabled = true,
            ["function"] = "rational", -- rational | gaussian | hyperbola
            alpha = 2.0,
            base_width = 0.50,
            base_height = 0.80,
            min_scale = 0.08,
            animation_speed = 12.0,
            visual_scale_ratio = 0.5, -- 0.0 = buffer resize only, 1.0 = visual scale only, 0.5 = 50/50 blend
            min_visual_scale   = 0.20,
        },
    },
})


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    -- Wallpaper daemon with retro synthwave wallpaper
    hl.exec_cmd("hyprpaper")

    -- Waybar retro status bar
    hl.exec_cmd("waybar")

    -- Terminal on startup
    hl.exec_cmd(terminal)
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,

        border_size = 2,

        -- Retro Synthwave / Cyberpunk Neon Borders (Hot Magenta to Electric Cyan)
        col = {
            active_border   = { colors = {"rgba(ff2a85ee)", "rgba(00f3ffee)"}, angle = 45 },
            inactive_border = "rgba(3d3455aa)",
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2,

        active_opacity   = 0.98,
        inactive_opacity = 0.88,

        -- Retro Neon Glow Shadow
        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 3,
            color        = 0x66ff2a85,
        },

        blur = {
            enabled   = true,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.25,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Snappy Retro animations
hl.curve("retroSnap",      { type = "bezier", points = { {0.2, 0.9}, {0.3, 1.1} } })
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},  {0.32, 1}   } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},     {1, 1}      } })

hl.animation({ leaf = "global",        enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 6,   bezier = "linear" })
hl.animation({ leaf = "windows",       enabled = true, speed = 5,   bezier = "retroSnap" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,   bezier = "retroSnap", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "linear",    style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2,   bezier = "linear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "linear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,   bezier = "easeOutQuint", style = "slide" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = 0x120e1c,
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
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
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

-- Retro Launcher, Universal Search, Widget & Lockscreen
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(search))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(retroHud))
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
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.exec_cmd("hyprctl dispatch swapwindow l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch swapwindow r"))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.exec_cmd("hyprctl dispatch swapwindow u"))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.exec_cmd("hyprctl dispatch swapwindow d"))

----------------------------------------------------
-- MULTI-MONITOR & WORKSPACE MANAGEMENT KEYBINDINGS --
----------------------------------------------------

-- Focus monitor above / below (External monitor is on top!)
hl.bind(mainMod .. " + ALT + up",    hl.dsp.exec_cmd("hyprctl dispatch focusmonitor u"))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.exec_cmd("hyprctl dispatch focusmonitor d"))
hl.bind(mainMod .. " + ALT + TAB",   hl.dsp.exec_cmd("hyprctl dispatch focusmonitor +1"))

-- Move Active Window to Monitor Above (External) / Below (Laptop)
hl.bind(mainMod .. " + SHIFT + CTRL + up",   hl.dsp.exec_cmd("hyprctl dispatch movewindow tomonitor u"))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.exec_cmd("hyprctl dispatch movewindow tomonitor d"))

-- Move Entire Active Workspace to Monitor Above / Below / Next
hl.bind(mainMod .. " + SHIFT + up",   hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor u"))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor d"))
hl.bind(mainMod .. " + SHIFT + M",    hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor +1"))

-- Swap Active Workspaces Between Both Monitors
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("/home/gopal/.local/bin/retro-swap-workspaces"))

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
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Media Player Keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

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

-- Retro HUD Floating Widget Rule
hl.window_rule({
    name  = "retro-hud-floating",
    match = { class = "retro-hud" },
    float = true,
    size  = "680 480",
})

-- Pavucontrol Floating
hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "pavucontrol|org.pulseaudio.pavucontrol" },
    float = true,
    size  = "700 500",
})
