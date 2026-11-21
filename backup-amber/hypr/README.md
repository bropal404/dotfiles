# Warm Retro Hyprland Theme

A warm, vintage-computer desktop: amber phosphor, cream, rust and olive on warm charcoal. Flat colours, square corners, bevelled buttons, inverse-video highlights, hard drop shadows and pixel-art wallpapers with no neon or glow. Includes multi-monitor setup (external monitor on top), the Hyperbolic resize plugin, Waybar, Wofi, universal search, Wlogout, Hyprlock, matching terminal colours and a launcher.

---

## 📁 Directory & File Map

Here is the exact index of what was modified, created, and installed across the system:

```
~/.config/
├── hypr/
│   ├── hyprland.lua                     # Main Hyprland Lua config (Monitors, Binds, Plugins, Styling)
│   ├── hyprpaper.conf                   # Wallpaper daemon configuration
│   ├── hyprlock.conf                    # Retro CRT lockscreen configuration
│   ├── wallpapers/
│   │   ├── retro_stripes.png            # 4K pixel-art 70s stripes on dithered charcoal (default)
│   │   ├── retro_plain.png              # Same without stripes
│   │   ├── *.svg                        # Vector sources
│   │   └── make_retro_wallpaper.py      # Generates SVG and renders PNG via rsvg-convert
│   ├── dms/colors.lua                   # Colors module (preserved)
│   └── README.md                        # This documentation file
│
├── waybar/
│   ├── config.jsonc                     # Waybar module layout (Launcher, Finder, Telemetry, Clock, Power)
│   └── style.css                        # Retro neon cyan/magenta styling, glowing borders, VT323 typography
│
├── wofi/
│   ├── config                           # Wofi launcher configuration
│   └── style.css                        # CRT monitor styling, scanline effects, neon selection highlights
│
├── wlogout/
│   ├── layout                           # Power menu action buttons (Lock, Logout, Suspend, Reboot, Shutdown)
│   └── style.css                        # Arcade cabinet button layout with distinct neon border accents
│
├── kitty/
│   ├── retro-theme.conf                 # Synthwave 80s terminal color palette
│   ├── kitty.conf                       # Kitty config (includes retro-theme.conf)
│   └── kitty.conf.backup.pre-retro      # Original kitty config backup
│
├── alacritty/
│   ├── alacritty.toml                   # Alacritty configuration with matching retro colors
│   └── alacritty.toml.backup.pre-retro  # Original alacritty config backup
│
└── fastfetch/
    └── retro.jsonc                      # Retro ASCII mainframe logo and system telemetry layout

~/.local/
├── bin/
│   ├── retro-swap-workspaces            # Dual-monitor workspace swapping tool
│   ├── waybar, wofi, wlogout,           # Robust wrapper scripts ensuring LD_LIBRARY_PATH
│   └── hyprlock, hyprpaper              # and user binary availability
│
└── share/fonts/retro/
    ├── VT323-Regular.ttf                # Classic CRT terminal monospace font
    └── PressStart2P-Regular.ttf         # 8-bit arcade pixel font
```

---

## 🎨 Palette

| Role | Hex | Used for |
| :--- | :--- | :--- |
| Background | `#1B1814` | Warm charcoal: bar, terminals, launcher |
| Surface | `#262019` | Buttons, input fields |
| Bevel light / dark | `#4A3F31` / `#0E0C0A` | Raised and pressed button edges, dividers |
| Foreground | `#E6D5B0` | Cream text |
| Dim | `#9A8A6E` | Secondary text, inactive workspaces |
| **Amber** (primary) | `#E08A2E` | Focus border, active workspace, clock, cursor |
| Mustard | `#D9B24A` | CPU, warnings |
| Rust | `#C0552B` | Power, errors, critical battery |
| Olive | `#8F9A4F` | Audio, charging |
| Faded teal | `#6F9488` | Memory |

**Glyphs:** `░▒▓` launcher, blinking `█` cursor, `◎` find, `▸` window title, `▁▂▃▄▅▆▇█` CPU/memory meters, `░░░░`→`████` battery, `⏻` power.

**Animations:** quick ease-out "CRT settle" curve with no overshoot, windows pop in at 92%, close with a snap, and workspaces slide horizontally. Inactive windows dim slightly, the bar cursor blinks, and critical battery flashes.

---

## 🖥️ Multi-Monitor Setup (External Monitor on Top)

Configured in `~/.config/hypr/hyprland.lua`:
- **Bottom Screen**: Internal laptop display (`eDP-1`) is set as the base monitor at `position = "auto"`.
- **Top Screen**: External displays (`HDMI-A-1`, `DP-1`, `DP-2`, and fallback `""`) are configured with `position = "auto-up"`.
- Any plugged-in monitor will automatically stack on top of the laptop display.

---

## 🧩 Window Resizing Plugin (Hyperbolic)

The dynamic window resizing plugin is preserved and configured in `~/.config/hypr/hyprland.lua`:
- **Binary Path**: `~/.local/lib/hyprland-plugins/hyperbolic.so`
- **Configuration**:
  - Function: `rational`
  - Base width: `0.50`
  - Base height: `0.80`
  - Animation speed: `12.0`
  - Visual scale blend ratio: `0.5`
- **Keybinding**: `Super + Space` automatically ensures the Hyperbolic plugin is active and toggles floating on the current window.

---

## ⌨️ Keybindings Cheat Sheet

### 🖥️ Multi-Monitor & Workspace Control
- `Super + Shift + Up` : Move current workspace to the **top (external) monitor**
- `Super + Shift + Down` : Move current workspace to the **bottom (laptop) monitor**
- `Super + Shift + M` : Move current workspace to next monitor
- `Super + Alt + S` : **Swap active workspaces between both monitors**
- `Super + Alt + Up` / `Down` : Shift focus to the monitor above / below
- `Super + Alt + Tab` : Cycle monitor focus
- `Super + Shift + Ctrl + Up` / `Down` : Move active window to monitor above / below
- `Super + Ctrl + Left` / `Right` / `Up` / `Down` : Swap active window position in tiled layout
- `Super + [1-9, 0]` : Switch to workspace 1–10
- `Super + Shift + [1-9, 0]` : Move focused window to workspace 1–10
- `Super + Scroll Wheel` : Cycle through existing workspaces
- **3-finger swipe left/right** : Switch workspace (slides horizontally)
- **4-finger swipe up / down** : Move current workspace to the monitor above / below

### 🚀 Applications & System Controls
- `Super + Return` : Open terminal (`kitty`)
- `Super + Q` or `Super + C` : Close focused window
- `Super + Space` : Toggle floating mode with Hyperbolic auto-resize
- `Super + R` or `Super + D` : Open App Launcher (rofi)
- `Super + S` : Open Finder (rofi: apps / run / windows / files)
- `Super + X` or `Super + M` : Open Retro Power Menu (`wlogout`, one row; keys L/E/U/R/S)
- `Super + L` : Lock screen with Retro CRT Lockscreen (`hyprlock`)
- `Super + E` : Open file manager (`dolphin`)
- `Super + V` : Toggle window float
- `Super + J` : Toggle split layout orientation

---

## 🔍 Launcher & Finder (rofi)

- `Super + R` / `Super + D` / bar **RUN**: app launcher.
- `Super + S` / bar **FIND**: rofi with **APPS / RUN / WINDOWS / FILES** modes. `Tab` switches mode.
- Config: `~/.config/rofi/config.rasi` and theme `~/.config/rofi/retro.rasi`. `~/.config/rofi/launch` falls back to wofi if rofi isn't installed.
- Install: `sudo pacman -S rofi`

---


## 🛡️ Backup Files

The previous neon/synthwave version of every themed file is in `~/.config/hypr/backup-neon/`.

All original pre-retro configurations were preserved with `.backup.pre-retro` extensions:
- `~/.config/hypr/hyprland.lua.backup.pre-retro`
- `~/.config/kitty/kitty.conf.backup.pre-retro`
- `~/.config/alacritty/alacritty.toml.backup.pre-retro`
