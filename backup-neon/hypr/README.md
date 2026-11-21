# 🕹️ Retro Synthwave / Cyber-Arcade Hyprland Theme

A comprehensive, retro-styled desktop environment for Hyprland featuring an 80s synthwave/CRT aesthetic, multi-monitor ergonomics (external monitor on top), window-movement resizing plugin support, custom Waybar status bar, Wofi launcher, universal search, Wlogout power menu, Hyprlock CRT lockscreen, matching terminal colorschemes, and an interactive telemetry HUD widget.

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
│   │   ├── retro_synthwave.png          # 4K Outrun sun, wireframe grid, mountains, starry sky
│   │   └── retro_grid.png               # Alternate CRT dark phosphor isometric grid
│   ├── dms/colors.lua                   # Colors module (preserved)
│   └── README.md                        # This documentation file
│
├── waybar/
│   ├── config.jsonc                     # Waybar module layout (Launcher, Search, Telemetry, Clock, HUD, Exit)
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
│   ├── retro-search                     # Universal search (Apps, Web `>`, Files `~`, Math `=`)
│   ├── retro-hud                        # Terminal-based floating telemetry HUD
│   ├── retro-hud-toggle                 # Quick toggle script for the retro HUD
│   ├── retro-swap-workspaces            # Dual-monitor workspace swapping tool
│   ├── waybar, wofi, wlogout,           # Robust wrapper scripts ensuring LD_LIBRARY_PATH
│   └── hyprlock, hyprpaper              # and user binary availability
│
└── share/fonts/retro/
    ├── VT323-Regular.ttf                # Classic CRT terminal monospace font
    └── PressStart2P-Regular.ttf         # 8-bit arcade pixel font
```

---

## 🎨 Theme Details & Palette

The desktop is styled around a high-contrast 1980s retro cyber-arcade palette:

| Element | Color Hex | Description |
| :--- | :--- | :--- |
| **Background** | `#120E1C` | Deep dark CRT purple-black |
| **Surface** | `#1C162C` | Dark violet container background |
| **Primary Accent** | `#FF2A85` | Hot Neon Magenta / Laser Pink |
| **Secondary Accent** | `#00F3FF` | Electric Neon Cyan |
| **Status / Success** | `#05FFA1` | Phosphor CRT Mint Green |
| **Warning / Attention**| `#FFE600` | Retro Arcade Yellow / Gold |
| **Battery / Heat** | `#FF9E3B` | Retro Neon Amber |
| **Foreground / Text** | `#F1EBF9` | Crisp retro phosphor cream white |
| **Muted Border** | `#3D3455` | Inactive borders and dividers |

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

### 🚀 Applications & System Controls
- `Super + Return` : Open terminal (`kitty`)
- `Super + Q` or `Super + C` : Close focused window
- `Super + Space` : Toggle floating mode with Hyperbolic auto-resize
- `Super + R` or `Super + D` : Open Retro App Launcher (`wofi`)
- `Super + S` : Open Retro Universal Search (`retro-search`)
- `Super + W` : Toggle Retro Telemetry HUD Widget (`retro-hud-toggle`)
- `Super + X` or `Super + M` : Open Retro Power Menu (`wlogout`)
- `Super + L` : Lock screen with Retro CRT Lockscreen (`hyprlock`)
- `Super + E` : Open file manager (`dolphin`)
- `Super + V` : Toggle window float
- `Super + J` : Toggle split layout orientation

---

## 🔍 Retro Universal Search Features (`Super + S`)

The custom `retro-search` utility supports smart prefixes:
1. **Application / Command**: Type any app name or command (e.g. `firefox`, `btop`, `code`).
2. **Web Search (`>`)**: Type `> search query` to search DuckDuckGo in your browser (e.g. `> arch linux hyprland`).
3. **File Search (`~`)**: Type `~ filename` to search files in `$HOME` and open them (e.g. `~ document.pdf`).
4. **Calculator (`=`)**: Type `= math expression` for instant calculation and clipboard copy (e.g. `= (1440 * 2) + 120`).

---

## 👾 Retro Telemetry HUD Widget (`Super + W`)

The floating HUD widget (`retro-hud`) provides:
- Custom retro ASCII mainframe fastfetch header.
- Real-time CPU core frequencies.
- Total active online CPU threads.
- 1m, 5m, 15m load averages.
- Storage disk utilization.
- Press `b` inside the HUD to instantly jump into `btop`.

---

## 🛡️ Backup Files

All original user configurations were preserved with `.backup.pre-retro` extensions:
- `~/.config/hypr/hyprland.lua.backup.pre-retro`
- `~/.config/kitty/kitty.conf.backup.pre-retro`
- `~/.config/alacritty/alacritty.toml.backup.pre-retro`
