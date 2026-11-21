# Hypr-Blur: Modern Frosted Glass Shell with Quickshell

A modern, minimal, aesthetic blurry Hyprland desktop environment featuring dynamic multi-pass Gaussian blur, Material You palette theming, custom Quickshell bottom bar, full Control Center (Wi-Fi, Bluetooth, Audio, Brightness, VPN), floating notification agent, 4K colorful modern art wallpaper, and a frosted glass lockscreen.

---

## 📁 System Architecture & File Map

```
~/.config/
├── hypr/
│   ├── hyprland.lua                     # Blurry Hyprland Lua configuration (Blur, Shadows, Animations, Binds)
│   ├── hyprpaper.conf                   # Wallpaper daemon loading 4K Modern Art wallpaper
│   ├── hyprlock.conf                    # Frosted glass blur lockscreen with modern clock & user card
│   ├── wallpapers/
│   │   ├── modern_art.png               # 4K Colorful Modern Art Wallpaper (Bauhaus / Chromatic Flow)
│   │   ├── modern_art_blurred.png       # 4K Gaussian blurred wallpaper for lockscreen
│   │   ├── modern_art.svg               # Vector source for modern art composition
│   │   └── make_modern_art_wallpaper.py # Python script to generate SVG & render 4K PNG
│   └── README.md                        # Documentation
│
├── quickshell/                          # Modern Material 3 Blurry Shell (autostarted via `qs`)
│   ├── shell.qml                        # Root shell loader (Bar variants, Notification toasts, IPC)
│   ├── Bar.qml                          # Modern bottom bar: launcher, workspaces, active apps, tray, pill, clock
│   ├── ControlCenter.qml                # Modern slide-out Control Center with full quick settings & subpages
│   ├── NotificationToasts.qml           # Floating notification toast agent (top-right, auto-dismiss, interactive)
│   ├── Launcher.qml                     # Minimal app launcher with type-to-filter & run
│   ├── Tile.qml                         # Quick setting interactive toggle tile with expand support
│   ├── M3Slider.qml                     # Material 3 expressive sliders for Volume and Brightness
│   ├── Net.qml                          # NetworkManager backend via nmcli (Wi-Fi, Ethernet, VPN)
│   ├── WifiList.qml                     # Wi-Fi network scanner, connect/disconnect, password entry
│   ├── BtList.qml                       # Bluetooth scanner, device connect, pair & forget
│   ├── VpnList.qml                      # WireGuard & NetworkManager VPN toggles
│   ├── Brightness.qml                   # Backlight control via sysfs & systemd-logind SetBrightness
│   ├── Notifs.qml                       # Notification daemon server & history storage
│   ├── NotificationItem.qml             # Notification item card with app icon, actions, and dismiss
│   ├── MediaCard.qml                    # MPRIS music player with album art & playback controls
│   ├── SysStats.qml                     # Realtime CPU, RAM, Disk, and Uptime telemetry
│   ├── Theme.qml                        # Material 3 design tokens & geometry
│   └── colors.json                      # Material You color scheme extracted from wallpaper via matugen
│
├── kitty/
│   └── kitty.conf                       # Kitty terminal with 0.85 background opacity for frosted blur
│
└── ~/.local/bin/
    └── brightnessctl                    # Native brightnessctl wrapper using systemd-logind D-Bus
```

---

## 🎨 Theme & Visual Design

- **Blur & Transparency**: 3-pass Gaussian blur with `size = 8`, `vibrancy = 0.25`, `contrast = 0.92`, and `noise = 0.015`.
- **Frosted Glass Windows**: Terminal and dolphin opacity set to `0.85-0.90` with soft diffused ambient shadows (`range = 22`, `render_power = 4`).
- **Harmonized Color Palette**: Dynamic Material You color scheme extracted directly from the 4K colorful modern art wallpaper using `matugen`, synchronizing border gradients, Quick Settings accents, sliders, and lockscreen styling.

---

## 🎛️ Quickshell Features & Controls

1. **Floating Bar**:
   - **App Launcher Button**: Custom Arch glyph (`󰣇`). Left-click opens Launcher; Right-click opens Power Menu (`wlogout`).
   - **Workspaces**: Dynamic workspace pills indicating occupied and active workspaces.
   - **Active Window Chips**: Click to focus; middle-click to close.
   - **Media Chip**: Appears automatically whenever media is playing; scroll to skip tracks; middle-click to play/pause.
   - **System Tray**: Native SNI tray icons with left/right/middle click and scroll events.
   - **Status Pill**: Shows live network, VPN active status, Bluetooth connection status, volume percentage, battery status, and unread notification badge. Click to toggle Control Center!
   - **Clock Pill**: Displays date and bold 12-hour/24-hour clock.

2. **Control Center (`Super + A` or click Status Pill)**:
   - **Wi-Fi**: Quick toggle tile + expandable Wi-Fi network list with password input and signal bars.
   - **Bluetooth**: Quick toggle tile + expandable Bluetooth device list with one-click pairing and connect.
   - **Volume**: Expressive M3 slider with mute toggle and live percentage.
   - **Brightness**: Expressive M3 slider with smooth backlight adjustment via logind D-Bus.
   - **VPN**: Quick toggle tile + expandable VPN list for WireGuard and NetworkManager VPN profiles.
   - **Notification Center**: Do Not Disturb toggle and notification history with "Clear all".
   - **System Telemetry**: Realtime CPU, Memory, and Disk usage with visual progress gauges.
   - **Media Card**: Full player controls with album cover art and seek slider.

3. **Notification Agent**:
   - Floating animated toast notifications in the top-right corner.
   - Supports rich text, app icons, urgency levels, and action buttons.
   - Automatically dismisses after 7 seconds, pauses when hovered.

4. **Blur Lockscreen (`Super + L`)**:
   - Frosted glass backdrop with Gaussian blur passes.
   - Oversized typography for time and date.
   - Central frosted glass card with user avatar, name, and pill-shaped password input field.
   - Live battery level indicator.

---

## ⌨️ Keybindings Cheat Sheet

### 🚀 Core Shortcuts
- `Super + Return` : Open Terminal (`kitty` with translucent blur)
- `Super + Q` / `Super + C` : Close focused window
- `Super + E` : Open File Manager (`dolphin`)
- `Super + V` : Toggle window floating mode
- `Super + Space` : Toggle floating mode with Hyperbolic auto-resizing
- `Super` (tap), `Super + R` / `Super + D` : Open Quickshell App Launcher
- `Super + A` or `Super + N` : **Open Quickshell Control Center**
- `Super + S` : Open Finder (`rofi`)
- `Super + L` : **Lock Screen (`hyprlock` blur lockscreen)**
- `Super + X` or `Super + M` : Open Power Menu (`wlogout`)
- `Super + Shift + Q` : Exit Hyprland

### 🖥️ Multi-Monitor & Workspaces
- `Super + Shift + Up` : Move current workspace to the top (external) monitor
- `Super + Shift + Down` : Move current workspace to the bottom (laptop) monitor
- `Super + Shift + M` : Move current workspace to next monitor
- `Super + Alt + S` : Swap active workspaces between both monitors
- `Super + Alt + Up` / `Down` : Focus monitor above / below
- `Super + [1-9, 0]` : Switch to workspace 1–10
- `Super + Shift + [1-9, 0]` : Move focused window to workspace 1–10
- `Super + \`` (grave) : Toggle Scratchpad workspace

### 🔊 Multimedia & Brightness
- `XF86AudioRaiseVolume` / `LowerVolume` : Volume up/down
- `XF86AudioMute` / `MicMute` : Toggle audio/microphone mute
- `XF86MonBrightnessUp` / `Down` : Increase/decrease screen brightness
- `XF86AudioPlay` / `Next` / `Prev` : Media playback control
