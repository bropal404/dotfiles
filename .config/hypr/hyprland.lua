-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- MODERN BLURRY HYPRLAND LUA CONFIGURATION                             --
-- With Quickshell (M3 Bar, Control Center, Notifications),             --
-- Multi-Monitor Stack, and Frosted Glass Aesthetics  --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Theming: let Qt apps (Dolphin etc.) read KDE settings via plasma-integration
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
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
    vrr      = 1,            -- adaptive sync on the 120Hz panel (2 = fullscreen only, if you see flicker)
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
local exitMenu      = "qs ipc call power toggle"   -- hold-to-confirm power menu (PowerMenu.qml)
local lockScreen    = os.getenv("HOME") .. "/.config/hypr/scripts/lock"  -- thumper + hyprlock + wind


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    -- Unlock KWallet with the login password (needs pam_kwallet5 in /etc/pam.d/greetd)
    hl.exec_cmd("/usr/lib/pam_kwallet_init")

    -- Wallpaper daemon (Colorful Modern Art Wallpaper)
    hl.exec_cmd("hyprpaper")

    -- Quickshell Dune shell (~/.config/quickshell)
    hl.exec_cmd("qs")

    -- Title card + horn once the shell is up
    hl.exec_cmd("sh -c 'for i in 1 2 3 4 5 6 7 8 9 10; do sleep 0.5; qs ipc call intro play && exit; done'")

end)


-----------------------
---- LOOK AND FEEL ----  DUNE: Arrakis at dusk
-----------------------
-- Palette (also used by Quickshell, hyprlock, kitty, rofi, wlogout):
--   night sky #161924   charcoal #1f1917   deep #0d0b0a
--   spice     #d98a4e   sand     #a96033   dune  #56331d
--   pale sand #eac5b2   ibad blue #8ec9ff (Fremen eyes, used sparingly)

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 6,

        border_size = 1,

        -- Thin "eclipse flare" border: pale light fading into spice and dusk.
        -- The angle slowly rotates (borderangle loop below) like light moving over dunes.
        col = {
            active_border   = { colors = { "rgba(eac5b2ee)", "rgba(d98a4ecc)", "rgba(56331d55)", "rgba(d98a4ecc)" }, angle = 30 },
            inactive_border = "rgba(1f191766)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "master",     -- master | dwindle  (Super+Ctrl+D / Super+Ctrl+Shift+D to switch)
    },

    decoration = {
        -- Brutalist, near-square corners like Arrakeen architecture
        rounding       = 3,
        rounding_power = 2,

        active_opacity   = 0.95,
        inactive_opacity = 0.86,
        dim_inactive     = true,
        dim_strength     = 0.12,
        dim_special      = 0.45,

        -- Long, low, warm shadow — like the sun setting behind a dune crest
        shadow = {
            enabled        = true,
            range          = 34,
            render_power   = 3,
            offset         = { 0, 10 },
            color          = "rgba(0a0604b0)",
            color_inactive = "rgba(0a060450)",
        },

        -- Hazy sandstorm glass: warm, desaturated, gritty
        blur = {
            enabled           = true,
            size              = 9,
            passes            = 3,
            vibrancy          = 0.12,
            vibrancy_darkness = 0.30,
            noise             = 0.045,   -- sand grain
            contrast          = 0.95,
            brightness        = 0.78,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
            popups            = true,

            -- Cursor stirs ripples through blurred glass (custom build feature): slow, heavy, like sand
            water = {
                strength = 14,
                radius   = 28,
                speed    = 0.45,
                duration = 6,
                damping  = 0.965,
            },
        },

        -- Wobble (jelly windows while dragging) is off
        wobble = { enabled = false },
    },

    animations = {
        enabled = true,
    },
})

-- Motion language: slow, heavy, deliberate. Things emerge from haze and settle like sand.
hl.curve("sandSettle", { type = "bezier", points = { {0.22, 1},    {0.36, 1} } })   -- easeOutQuint: fast start, long silky settle
hl.curve("spring",     { type = "bezier", points = { {0.34, 1.35}, {0.64, 1} } })   -- soft spring overshoot
hl.curve("glide",      { type = "bezier", points = { {0.65, 0},    {0.35, 1} } })   -- easeInOutCubic for moves between places
hl.curve("haze",       { type = "bezier", points = { {0.25, 0.8},  {0.25, 1} } })   -- gentle fade
hl.curve("wind",       { type = "bezier", points = { {0.5, 0},     {0.75, 0} } })   -- accelerate away (exits)
hl.curve("linear",     { type = "bezier", points = { {0, 0},       {1, 1} } })

-- Vertical language: the external monitor sits ABOVE the laptop, so workspaces, panels and
-- windows travel up/down rather than left/right.
hl.animation({ leaf = "global",        enabled = true, speed = 5,   bezier = "sandSettle" })
hl.animation({ leaf = "border",        enabled = true, speed = 6,   bezier = "haze" })
hl.animation({ leaf = "borderangle",   enabled = true, speed = 100, bezier = "linear", style = "loop" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3,   bezier = "haze",       style = "popin 100%" })   -- plain quick fade, no scaling
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.5, bezier = "haze",       style = "popin 100%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4.5, bezier = "sandSettle" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 4,   bezier = "haze" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,   bezier = "haze" })
hl.animation({ leaf = "fadeDim",       enabled = true, speed = 5,   bezier = "haze" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,   bezier = "sandSettle", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 3,   bezier = "glide",      style = "slide" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,   bezier = "sandSettle", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "sandSettle", style = "slidefadevert 35%" })

hl.config({
    dwindle = {
        preserve_split      = true,
        smart_split         = false,
        smart_resizing      = true,
    },
    -- Master layout (from old config): big master on the left, stack on the right.
    -- New windows join the stack (at the top) instead of taking over the master slot.
    master = {
        new_status           = "slave",
        new_on_top           = true,
        mfact                = 0.6,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = 0x0d0b0a,
    },
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})

-- Scratchpad (special:magic): windows sit inset from the edges (replaces the deprecated
-- dwindle/master special_scale_factor = 0.8)
hl.workspace_rule({ workspace = "special:magic", gaps_out = { top = 60, right = 110, bottom = 60, left = 110 } })

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:hyper,shift:both_capslock",  -- Caps Lock = Hyper (MOD3); both Shifts = Caps Lock
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- 3-finger horizontal swipe: switch workspace (matches the horizontal slide animation)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace"
})

-- 3-finger swipe up / down: roll the stack in master layout (same as HYPER+F / HYPER+SHIFT+F)
hl.gesture({
    fingers   = 3,
    direction = "up",
    action    = function() if LayoutOf() == "master" then hl.dispatch(hl.dsp.layout("rollnext")) end end,
})
hl.gesture({
    fingers   = 3,
    direction = "down",
    action    = function() if LayoutOf() == "master" then hl.dispatch(hl.dsp.layout("rollprev")) end end,
})

-- 3-finger pinch: toggle fullscreen on the focused window (same as SUPER+F)
hl.gesture({
    fingers   = 3,
    direction = "pinch",
    action    = "fullscreen",
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
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Floating-only workspace (SUPER+SPACE): turns the *current workspace* into a classic stacking
-- desktop. Windows float, are resized and cascaded evenly from the top left to the bottom right, new
-- windows join the cascade, and a Quickshell icon dock (FloatDock.qml) appears on the left.
-- Toggling off tiles back only the windows this mode floated.
local floatWs   = {}   -- workspace id -> true while float mode is on
FloatWorkspaces = floatWs  -- (global, for debugging: hyprctl eval "FloatWorkspaces[20]=true")
local floatedBy = {}   -- window address -> true if float mode (not you) floated it

local DOCK_SPACE = 72  -- px kept free on the left for the dock
local EDGE       = 6   -- gap to the other screen edges (= gaps_out)
local CASCADE_W, CASCADE_H = 1200, 700 -- cascaded window size (logical px, shrunk if the screen is smaller)

-- Transient confirmation toast via Quickshell (scripts/toast); falls back to a notification.
local function toast(title, body, icon)
    hl.exec_cmd(string.format("%s/.config/hypr/scripts/toast %q %q %q", os.getenv("HOME"), title, body or "", icon or ""))
end

-- State file: read by the dock, and re-read here so float mode survives a config reload.
local floatState = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr/"
    .. (os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "default") .. "/floatws"

local function save_float_state()
    local f = io.open(floatState, "w")
    if not f then return end
    for id in pairs(floatWs) do f:write("ws ", tostring(id), "\n") end
    for addr in pairs(floatedBy) do f:write("win ", addr, "\n") end
    f:close()
end

do
    local f = io.open(floatState, "r")
    if f then
        for line in f:lines() do
            local kind, v = line:match("^(%a+) (%S+)$")
            if kind == "ws" and tonumber(v) then floatWs[math.tointeger(tonumber(v))] = true
            elseif kind == "win" then floatedBy[v] = true end
        end
        f:close()
    end
    save_float_state()
end

local function wsOf(w)
    local ok, id = pcall(function() return w.workspace and w.workspace.id end)
    return ok and id or nil
end

local function float_window(w)
    local ok, fl = pcall(function() return w.floating end)
    if not ok or fl then return end
    floatedBy[w.address] = true
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
end

-- Usable rectangle of a monitor (logical px) and the cascade window size inside it.
local function cascade_area(mon)
    local r = mon.reserved
    local x = mon.x + r.left + DOCK_SPACE
    local y = mon.y + r.top + EDGE
    local aw = math.floor(mon.width / mon.scale) - r.left - r.right - DOCK_SPACE - EDGE
    local ah = math.floor(mon.height / mon.scale) - r.top - r.bottom - 2 * EDGE
    return x, y, aw, ah, math.min(CASCADE_W, aw), math.min(CASCADE_H, ah)
end

-- Put window at fraction t (0 = top left, 1 = bottom right) of the cascade and raise it.
local function cascade_one(w, t)
    pcall(function()
        local x, y, aw, ah, pw, ph = cascade_area(w.monitor)
        hl.dispatch(hl.dsp.window.resize({ x = pw, y = ph, window = w }))
        hl.dispatch(hl.dsp.window.move({ x = x + math.floor((aw - pw) * t), y = y + math.floor((ah - ph) * t), window = w }))
        hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = w }))
    end)
end

-- Cascade every window on a workspace, one after another so you can watch them fan out.
-- Least recently used goes top left; the focused window ends up bottom right, on top.
local function cascade(id)
    local wins = {}
    for _, w in ipairs(hl.get_windows({ workspace = id, floating = true })) do
        if not w.hidden then wins[#wins + 1] = w end
    end
    table.sort(wins, function(a, b) return a.focus_history_id > b.focus_history_id end)
    for i, w in ipairs(wins) do
        local t = #wins > 1 and (i - 1) / (#wins - 1) or 0.5
        hl.timer(function() if floatWs[id] then cascade_one(w, t) end end, { timeout = 1 + (i - 1) * 70, type = "oneshot" })
    end
end

local function on_window_arrived(w)
    if not (w and floatWs[wsOf(w)]) then return end
    float_window(w)
    save_float_state()
    -- let the app settle, then give it the next step of the diagonal (existing windows stay put)
    hl.timer(function()
        local n = #hl.get_windows({ workspace = wsOf(w), floating = true })
        cascade_one(w, ((n - 1) % 6) / 5)
    end, { timeout = 80, type = "oneshot" })
end
hl.on("window.open", on_window_arrived)
hl.on("window.move_to_workspace", on_window_arrived)

-- Used by the dock: focus a window and bring it to the front.
function FloatFocus(address)
    local target = "address:" .. address
    hl.dispatch(hl.dsp.focus({ window = target }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = target }))
end

function ToggleFloatWorkspace()
    local ws = hl.get_active_workspace()
    local id = ws and ws.id
    if not id then return end

    if floatWs[id] then
        floatWs[id] = nil
        for _, w in ipairs(hl.get_windows({ workspace = id, floating = true })) do
            if floatedBy[w.address] then
                floatedBy[w.address] = nil
                hl.dispatch(hl.dsp.window.float({ action = "disable", window = w }))
            end
        end
        toast("Workspace " .. id, "Tiling", "󰕮")
    else
        floatWs[id] = true
        for _, w in ipairs(hl.get_windows({ workspace = id, floating = false })) do
            float_window(w)
        end
        hl.timer(function() cascade(id) end, { timeout = 80, type = "oneshot" })
        toast("Workspace " .. id, "Floating only", "󰖲")
    end
    save_float_state()
end
hl.bind(mainMod .. " + SPACE", ToggleFloatWorkspace)

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
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })  -- Super+Shift+drag also resizes (left button)

-- Laptop Multimedia & Audio Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("sh -c 'wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+; qs ipc call osd volume'"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; qs ipc call osd volume'"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("sh -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; qs ipc call osd volume'"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("sh -c 'brightnessctl set 5%+; qs ipc call osd brightness'"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("sh -c 'brightnessctl set 5%-; qs ipc call osd brightness'"),                          { locked = true, repeating = true })

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
hl.layer_rule({ name = "qs-osd-blur",            match = { namespace = "^qs-osd$" },            blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "qs-toast-blur",            match = { namespace = "^qs-toast$" },            blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "qs-dock-blur",             match = { namespace = "^qs-dock$" },             blur = true, ignore_alpha = 0, no_anim = true })
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
OPACITY_RULES = {}   -- global: toggled by scripts/powermode (opaque windows when blur is off)
OPACITY_RULES[#OPACITY_RULES+1] = hl.window_rule({
    name  = "kitty-opacity",
    match = { class = "^(kitty|Alacritty)$" },
    opacity = 0.88,
})

OPACITY_RULES[#OPACITY_RULES+1] = hl.window_rule({
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


---------------------------------------------------
---- CARRIED OVER FROM OLD CONFIG ----
---------------------------------------------------

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Window state
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({}))

-- Pin active window to all workspaces (auto-floats tiled windows since Hyprland requires floating to pin)
local function toggle_pin_window()
    local win = hl.get_active_window()
    if not win then return end
    if win.pinned then
        hl.dispatch(hl.dsp.window.pin({ window = win }))
        toast("Window", "Unpinned", "󰤱")
    else
        if not win.floating then
            hl.dispatch(hl.dsp.window.float({ action = "enable", window = win }))
        end
        hl.dispatch(hl.dsp.window.pin({ window = win }))
        toast("Window", "Pinned to all workspaces", "󰐃")
    end
end
hl.bind(mainMod .. " + Y", toggle_pin_window)
hl.bind(mainMod .. " + SHIFT + P", toggle_pin_window)

-- Floating presets: float + resize + center (old SHIFT+V / B / N)
local function float_preset(w, h)
    return function()
        hl.dispatch(hl.dsp.window.float({ action = "enable" }))
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
        hl.dispatch(hl.dsp.window.center({}))
    end
end
hl.bind(mainMod .. " + SHIFT + V", float_preset(900, 500))
hl.bind(mainMod .. " + SHIFT + B", float_preset(1200, 700))
hl.bind(mainMod .. " + SHIFT + N", float_preset(1600, 900))

-- SUPER+= / SUPER+- : grow / shrink the focused floating window around its centre, keeping its shape
function ScaleWindow(factor, w)   -- w defaults to the focused window
    w = w or hl.get_active_window()
    if not w then return end
    if not w.floating then toast("Scale window", "Float it first (Super+V)", "󰖲") return end
    local function xy(v) return v.x or v[1], v.y or v[2] end
    local x, y = xy(w.at)
    local cw, ch = xy(w.size)
    local mon, r = w.monitor, w.monitor.reserved
    local mx, my = mon.x + r.left, mon.y + r.top
    local mw = math.floor(mon.width / mon.scale) - r.left - r.right
    local mh = math.floor(mon.height / mon.scale) - r.top - r.bottom
    -- limit the factor (not each side) so the aspect ratio survives
    local f = factor > 1 and math.max(1, math.min(factor, mw / cw, mh / ch))
                          or math.min(1, math.max(factor, 320 / cw, 200 / ch))
    local nw, nh = math.floor(cw * f + 0.5), math.floor(ch * f + 0.5)
    -- same centre, nudged back inside the screen if it would stick out
    local nx = math.max(mx, math.min(math.floor(x + (cw - nw) / 2), mx + mw - nw))
    local ny = math.max(my, math.min(math.floor(y + (ch - nh) / 2), my + mh - nh))
    hl.dispatch(hl.dsp.window.resize({ x = nw, y = nh, window = w }))
    hl.dispatch(hl.dsp.window.move({ x = nx, y = ny, window = w }))
end
hl.bind(mainMod .. " + equal", function() ScaleWindow(1.1) end,     { repeating = true })
hl.bind(mainMod .. " + minus", function() ScaleWindow(1 / 1.1) end, { repeating = true })

-- Gaps: SUPER+G = no gaps, SUPER+SHIFT+G = compact gaps, SUPER+CTRL+G = default
hl.bind(mainMod .. " + G",               function() hl.config({ general = { gaps_in = 0, gaps_out = 0 } }) end)
hl.bind(mainMod .. " + SHIFT + G",       function() hl.config({ general = { gaps_in = 3, gaps_out = 5 } }) end)
hl.bind(mainMod .. " + CTRL + G",        function() hl.config({ general = { gaps_in = 5, gaps_out = 10 } }) end)

-- ALT+TAB / ALT+SHIFT+TAB: switch windows on the current workspace, most recently used first.
-- The order is frozen while ALT is held, so one tap flips to the previous window and
-- further taps walk further back; releasing ALT commits.
local altList, altIndex = nil, 1

function AltTab(step)
    local ws = hl.get_active_workspace()
    if not ws then return end
    if not altList or altList.ws ~= ws.id then
        local wins = {}
        for _, w in ipairs(hl.get_windows({ workspace = ws.id })) do
            if w.mapped and not w.hidden then wins[#wins + 1] = w end
        end
        table.sort(wins, function(a, b) return a.focus_history_id < b.focus_history_id end)
        altList, altIndex = { ws = ws.id }, 1
        for i, w in ipairs(wins) do altList[i] = w.address end
    end
    if #altList < 2 then return end
    altIndex = (altIndex - 1 + step) % #altList + 1
    FloatFocus(altList[altIndex])   -- focus and raise (works tiled or floating)
end
hl.bind("ALT + TAB",         function() AltTab(1) end,  { repeating = true })
hl.bind("ALT + SHIFT + TAB", function() AltTab(-1) end, { repeating = true })
hl.bind("ALT + Alt_L", function() altList = nil end, { release = true, ignore_mods = true, non_consuming = true, transparent = true })

-- Layout switching + master-layout controls
-- Layouts are per workspace: switching affects only the current one (everything else stays master),
-- and a workspace goes back to master once its last window is gone.
local wsLayout = {}   -- workspace id -> { layout, selector }, only for non-master workspaces

function LayoutOf()   -- layout of the active workspace
    local ws = hl.get_active_workspace()
    return ws and wsLayout[ws.id] and wsLayout[ws.id].layout or "master"
end

local function apply_layout(id, selector, name)
    wsLayout[id] = name ~= "master" and { layout = name, selector = selector } or nil
    hl.workspace_rule({ workspace = selector, layout = name })
end

function SetLayout(name, ws)   -- ws defaults to the active workspace
    ws = ws or hl.get_active_workspace()
    if not ws then return end
    apply_layout(ws.id, ws.id > 0 and tostring(ws.id) or ws.name, name)
    toast("Workspace " .. ws.id, name:sub(1, 1):upper() .. name:sub(2), "󰕮")
end

local function reset_empty_layouts()
    for id, l in pairs(wsLayout) do
        if #hl.get_windows({ workspace = id }) == 0 then apply_layout(id, l.selector, "master") end
    end
end
-- checked a moment later, once the window has actually left the workspace
for _, event in ipairs({ "window.close", "window.destroy", "window.move_to_workspace" }) do
    hl.on(event, function() hl.timer(reset_empty_layouts, { timeout = 150, type = "oneshot" }) end)
end
hl.bind(mainMod .. " + CTRL + D",         function() SetLayout("dwindle") end)
hl.bind(mainMod .. " + CTRL + SHIFT + D", function() SetLayout("master") end)
hl.bind(mainMod .. " + backslash",         hl.dsp.layout("orientationnext"))
hl.bind(mainMod .. " + CTRL + backslash",  hl.dsp.layout("orientationprev"))
hl.bind(mainMod .. " + SHIFT + backslash", hl.dsp.layout("mfact exact 0.5"))
hl.bind(mainMod .. " + bracketright",      hl.dsp.layout("mfact +0.05"), { repeating = true })
hl.bind(mainMod .. " + bracketleft",       hl.dsp.layout("mfact -0.05"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.layout("removemaster"))

-- Grouping (tabbed windows): SUPER+T toggle, SUPER+ALT+left/right switch tab
hl.bind(mainMod .. " + T",          hl.dsp.group.toggle({}))
hl.bind(mainMod .. " + ALT + left",  hl.dsp.group.prev({}))
hl.bind(mainMod .. " + ALT + right", hl.dsp.group.next({}))

-- Workspace navigation
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + comma",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + TAB",    hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + CTRL + grave", hl.dsp.focus({ workspace = "empty" }))
hl.bind("mouse:276", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("mouse:275", hl.dsp.focus({ workspace = "m-1" }))

-- Move window to prev/next workspace, or to a fresh empty one (follows the window)
hl.bind(mainMod .. " + CTRL + bracketleft",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + CTRL + period",       hl.dsp.window.move({ workspace = "empty" }))

-- Keyboard resize: SUPER+CTRL+SHIFT+arrows/hjkl, plus a persistent resize mode (SUPER+CTRL+R, Esc to leave)
local step = 30
for key, d in pairs({
    left = { -step, 0 }, right = { step, 0 }, up = { 0, -step }, down = { 0, step },
    h = { -step, 0 },    l = { step, 0 },     k = { 0, -step },   j = { 0, step },
}) do
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. key,
        hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }), { repeating = true })
end

hl.bind(mainMod .. " + CTRL + R", hl.dsp.submap("resize"))
hl.define_submap("resize", "reset", function()
    for key, d in pairs({
        left = { -step, 0 }, right = { step, 0 }, up = { 0, -step }, down = { 0, step },
        h = { -step, 0 },    l = { step, 0 },     k = { 0, -step },   j = { 0, step },
    }) do
        hl.bind(key, hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }), { repeating = true })
    end
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Screenshots (scripts/screenshot needs grim, slurp, wl-clipboard; satty/swappy for editing)
hl.bind("Print",              hl.dsp.exec_cmd(scripts .. "/screenshot area"))
hl.bind("SHIFT + Print",      hl.dsp.exec_cmd(scripts .. "/screenshot full"))
hl.bind("CTRL + Print",       hl.dsp.exec_cmd(scripts .. "/screenshot edit"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scripts .. "/screenshot area"))

-- Suspend; external-monitor (DDC) brightness on SUPER + brightness keys
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("systemctl suspend"))   -- instant sleep (hypridle locks first)
hl.bind(mainMod .. " + XF86MonBrightnessUp",   hl.dsp.exec_cmd("ddcutil setvcp 10 + 10"), { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil setvcp 10 - 10"), { locked = true, repeating = true })

-- Window rules from old config
hl.window_rule({ name = "float-utils",
    match = { class = "^(blueman-manager|CachyOSHello|zenity|org.kde.polkit-kde-authentication-agent-1|hyprpolkitagent|vlc)$" },
    float = true })
hl.window_rule({ name = "float-portals",
    match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)$" },
    float = true })
hl.window_rule({ name = "float-file-dialogs",
    match = { class = "^$", title = "^(Save File|Open File)$" }, float = true })
hl.window_rule({ name = "pip-float",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true, pin = true, no_dim = true })
hl.window_rule({ name = "htop-float",
    match = { class = "^htop-float$" }, float = true, center = true, size = "1200 800" })
hl.window_rule({ name = "no-dim-media",
    match = { class = "^(firefox|librewolf|zen|chromium|google-chrome|vlc|mpv|imv)$" }, no_dim = true })
OPACITY_RULES[#OPACITY_RULES+1] = hl.window_rule({ name = "editor-opacity",
    match = { class = "^(dev.zed.Zed|code)$" }, opacity = 0.92 })

-- Idle: lock/dim/suspend (hypridle.conf), and fix slow app launches via env import
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME XDG_MENU_PREFIX")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("hypridle")
end)


-------------------------
---- DUNE EXTRAS ----
-------------------------
-- ── HYPER LAYER (Caps Lock) ──────────────────────────────────────────────
local hyper = "MOD3"
local function hb(key, action, opts) hl.bind(hyper .. " + " .. key, action, opts) end

-- Dune
hb("W", hl.dsp.exec_cmd("qs ipc call sand toggle"))          -- drifting sand on/off
hb("G", hl.dsp.exec_cmd("qs ipc call sand gust"))            -- summon a gust
hb("I", hl.dsp.exec_cmd("qs ipc call intro play"))           -- replay title card
hb("M", hl.dsp.exec_cmd(scripts .. "/sfx toggle"))           -- mute sound effects

-- Master layout (as in the old config): Hyper+D swap focused window with master,
-- Hyper+F / Hyper+Shift+F roll focus through the stack, Hyper+A jump to master
hb("D", hl.dsp.layout("swapwithmaster"))
hb("F", hl.dsp.layout("rollnext"))
hb("SHIFT + F", hl.dsp.layout("rollprev"))
hb("A", hl.dsp.layout("focusmaster"))

-- Fresh starts: terminal / launcher on a new empty workspace
hb("RETURN", function()
    hl.dispatch(hl.dsp.focus({ workspace = "empty" }))
    hl.exec_cmd(terminal)
end)
hb("SPACE", function()
    hl.dispatch(hl.dsp.focus({ workspace = "empty" }))
    hl.exec_cmd(menu)
end)

-- Toggles
hb("O", function()
    hl.config({ animations = { enabled = false } })
    toast("Animations", "Off", "󰑙")
end)
hb("P", function()
    hl.config({ animations = { enabled = true } })
    toast("Animations", "On", "󰑙")
end)
hb("L", hl.dsp.exec_cmd(scripts .. "/caffeine"))   -- caffeine: hypridle off = screen stays awake

-- Windows & workspaces
-- Hyper + number moves active window to that workspace (1-10)
for i = 1, 10 do
    local key = tostring(i % 10)
    hb(key, hl.dsp.window.move({ workspace = i }))
end

hb("Y", toggle_pin_window)                                    -- pin window to all workspaces
hb("T", hl.dsp.group.toggle({}))                              -- tab group
hb("bracketleft",  hl.dsp.window.move({ workspace = "-1" }))  -- carry window to prev workspace
hb("bracketright", hl.dsp.window.move({ workspace = "+1" }))  -- carry window to next workspace
hb("backslash",    hl.dsp.window.move({ workspace = "empty" }))
hb("SHIFT + up",   hl.dsp.workspace.move({ monitor = "u" }))   -- push workspace to monitor above
hb("SHIFT + down", hl.dsp.workspace.move({ monitor = "d" }))   -- push workspace to laptop below
-- Move the focused window around (swaps with the neighbour / moves between columns)
hb("left",  hl.dsp.window.move({ direction = "left" }))
hb("right", hl.dsp.window.move({ direction = "right" }))
hb("up",    hl.dsp.window.move({ direction = "up" }))
hb("down",  hl.dsp.window.move({ direction = "down" }))
-- Master layout: cycle focus through the windows
hb("S",         hl.dsp.layout("cyclenext"))
hb("SHIFT + S", hl.dsp.layout("cycleprev"))

-- Intro and sand layers: no blur, no layer animation (they animate themselves)
hl.layer_rule({ name = "qs-intro-noanim", match = { namespace = "^qs-(intro|sandstorm)$" }, no_anim = true })


------------------------------------------------------------
---- FEATURES ADDED 2026-11-22: scrolling, workspaces,   ----
---- night light, colour picker, overview, find-cursor   ----
------------------------------------------------------------

-- Workspaces 1-4 live on the external monitor (above), 5-8 on the laptop (below).
-- If the external is unplugged they simply fall back to the laptop.
-- (Default per-workspace monitor/layout rules and app->workspace pinning removed 2026-11-24:
--  workspaces are now plain/dynamic; layouts are per workspace, see SetLayout.)

-- Pin apps to named homes (silent: never yanks you away from what you're doing)

-- Layouts: SUPER+CTRL+S = scrolling (D = dwindle, SHIFT+D = master, defined above)
hl.bind(mainMod .. " + CTRL + S", function() SetLayout("scrolling") end)
hl.bind(hyper .. " + TAB", function()   -- cycle master -> dwindle -> scrolling
    local nxt = { master = "dwindle", dwindle = "scrolling", scrolling = "master" }
    SetLayout(nxt[LayoutOf()])
end)
-- Scrolling controls (HYPER+...): resize column, fit, swap columns
hb("equal", hl.dsp.layout("colresize +0.1"), { repeating = true })
hb("minus", hl.dsp.layout("colresize -0.1"), { repeating = true })
hb("B", hl.dsp.layout("colresize +conf"))   -- cycle 1/3 · 1/2 · 2/3 · full
hb("V", hl.dsp.layout("fit visible"))
hb("U", hl.dsp.layout("promote"))           -- pull window into its own column

-- Night light (hyprsunset): warm after 20:00 automatically; HYPER+N toggles by hand
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd(scripts .. "/powermode watch")   -- 48Hz + no blur/sand on battery, full eye-candy on AC
end)
hb("N", hl.dsp.exec_cmd(scripts .. "/nightlight"))

-- Colour picker: HYPER+C -> click a pixel, hex goes to the clipboard
hb("C", hl.dsp.exec_cmd("sh -c 'command -v hyprpicker >/dev/null || { " .. scripts .. "/toast \"hyprpicker missing\" \"sudo pacman -S hyprpicker\"; exit; }; c=$(hyprpicker -a -f hex) && " .. scripts .. "/toast Colour \"$c\" 󰏘'"))

-- Find the cursor: HYPER+E pulses rings around it (Quickshell Locator.qml)
hb("E", hl.dsp.exec_cmd("sh -c 'qs ipc call locator ping $(hyprctl cursorpos | tr -d \" \" | tr , \" \")'"))

-- Scroll the scrolling-layout strip:
--   4-finger horizontal swipe on the touchpad drags the strip (3-finger stays workspace switch)
--   SUPER+SHIFT + mouse wheel steps column by column
hl.gesture({ fingers = 4, direction = "horizontal", action = "scroll_move" })
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + SHIFT + mouse_up",   hl.dsp.layout("move -col"))
