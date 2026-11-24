#!/usr/bin/env bash
# Dune dotfiles installer (Arch / CachyOS).
#
#   ./install.sh [--yes] [--dry-run] [--no-packages] [--tlp] [--greeter]
#
#   --yes          don't ask for confirmation
#   --dry-run      print what would happen, change nothing
#   --no-packages  skip installing packages
#   --tlp          also install the TLP drop-in + sudoers rule (HP Pavilion Plus 14 specific!)
#   --greeter      also install the greetd/Quickshell login screen (edits /etc/greetd/config.toml)
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config"
YES=0 DRY=0 PKGS=1 TLP=0 GREETER=0

for a in "$@"; do
  case "$a" in
    --yes|-y) YES=1 ;;
    --dry-run|-n) DRY=1 ;;
    --no-packages) PKGS=0 ;;
    --tlp) TLP=1 ;;
    --greeter) GREETER=1 ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

run() { if ((DRY)); then printf '[dry-run] %s\n' "$*"; else "$@"; fi; }
say() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }

cat <<'WARN'

  ┌──────────────────────────────── WARNING ────────────────────────────────┐
  │ Parts of this configuration were written by an AI assistant (Claude).   │
  │ It has been used on one machine only and has NOT been reviewed line by  │
  │ line. Read hyprland.lua and the scripts before installing, and expect   │
  │ to tweak things.                                                        │
  │                                                                         │
  │ Also be aware:                                                          │
  │  • It targets a CUSTOM Hyprland build (decoration.wobble and            │
  │    decoration.blur.water do not exist upstream) and Hyprland >= 0.57    │
  │    with the Lua config format. On stock Hyprland those options error.   │
  │  • Monitor names (HDMI-A-1 / eDP-1), VRR, power and TLP settings are    │
  │    tuned for one laptop. Adjust them for your hardware.                 │
  │  • Existing ~/.config/{hypr,quickshell,kitty,rofi,wlogout} are moved    │
  │    to *.bak-<timestamp> first, not deleted.                             │
  └─────────────────────────────────────────────────────────────────────────┘

WARN

if ((!YES && !DRY)); then
  read -r -p "Continue? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted."; exit 1; }
fi
[[ $EUID -ne 0 ]] || { echo "run as your normal user, not root (sudo is used where needed)." >&2; exit 1; }

# ── 1. packages ─────────────────────────────────────────────────────────────
PACKAGES=(
  hyprland hyprpaper hypridle hyprlock hyprsunset hyprpicker   # compositor + friends
  quickshell                                                    # the shell UI (qs)
  kitty dolphin rofi                                            # apps used by binds
  brightnessctl playerctl wireplumber pipewire libnotify        # media / brightness / notify-send / pw-play
  grim slurp swappy wl-clipboard                                # screenshots
  ddcutil python                                                # external brightness / generators
  ttf-ibmplex-mono-nerd                                         # kitty font (BlexMono Nerd Font); name may differ on your distro
)

if ((PKGS)); then
  command -v pacman >/dev/null || { echo "pacman not found — install the packages by hand (see PACKAGES in this script)." >&2; exit 1; }
  say "Installing packages"
  found=() missing=()
  for p in "${PACKAGES[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then found+=("$p"); else missing+=("$p"); fi
  done
  run sudo pacman -S --needed "${found[@]}"
  if ((${#missing[@]})); then
    helper=$(command -v paru || command -v yay || true)
    if [[ -n "$helper" ]]; then
      say "Not in the official repos, trying AUR: ${missing[*]}"
      run "$helper" -S --needed "${missing[@]}"
    else
      echo "NOTE: not in the official repos and no AUR helper found: ${missing[*]}" >&2
    fi
  fi
fi

# ── 2. config + fonts ───────────────────────────────────────────────────────
ts=$(date +%Y%m%d-%H%M%S)
run mkdir -p "$CFG"
for d in hypr quickshell kitty rofi wlogout; do
  [[ -d "$SRC/.config/$d" ]] || continue
  if [[ -e "$CFG/$d" ]]; then
    say "Backing up ~/.config/$d -> $d.bak-$ts"
    run mv "$CFG/$d" "$CFG/$d.bak-$ts"
  fi
  say "Installing ~/.config/$d"
  run cp -a "$SRC/.config/$d" "$CFG/$d"
done

say "Installing fonts (Lexend, Michroma — SIL OFL)"
run mkdir -p "$HOME/.local/share/fonts/dune"
run cp -a "$SRC"/.local/share/fonts/dune/. "$HOME/.local/share/fonts/dune/"
run fc-cache -f

# A few files hard-code the original author's home directory. Point them at this user.
if [[ "$HOME" != "/home/gopal" ]] && ((!DRY)); then
  say "Rewriting /home/gopal -> $HOME"
  grep -rIl "/home/gopal" "$CFG"/{hypr,quickshell,rofi} 2>/dev/null | xargs -r sed -i "s|/home/gopal|$HOME|g"
  sed -i "s/DUNE_GREETER_USER=gopal/DUNE_GREETER_USER=$USER/" "$CFG/hypr/greeter/install.sh" 2>/dev/null || true
fi
run chmod +x "$CFG"/hypr/scripts/* "$CFG/rofi/launch" "$CFG/hypr/greeter/install.sh" 2>/dev/null || true

# ── 3. optional: TLP (laptop-specific) ──────────────────────────────────────
if ((TLP)); then
  say "Installing TLP drop-in and sudoers rule (HP Pavilion Plus 14 / Ryzen 8845HS tuned)"
  run sudo pacman -S --needed tlp
  run sudo install -Dm644 "$SRC/.config/hypr/tlp/10-pavilion-8845hs.conf" /etc/tlp.d/10-pavilion-8845hs.conf
  tmp=$(mktemp); sed "s/^gopal /$USER /" "$SRC/.config/hypr/tlp/sudoers-powermode" > "$tmp"
  run sudo visudo -cf "$tmp"
  run sudo install -m 0440 -o root -g root "$tmp" /etc/sudoers.d/tlp-powermode
  run sudo systemctl enable --now tlp.service
  rm -f "$tmp"
fi

# ── 4. optional: greeter ────────────────────────────────────────────────────
if ((GREETER)); then
  say "Installing the greetd greeter (backup kept as /etc/greetd/config.toml.pre-dune)"
  run sudo sh "$CFG/hypr/greeter/install.sh"
fi

say "Done."
cat <<MSG

Next steps:
  • Log out and pick Hyprland (or run: hyprctl reload  if already inside it).
  • Check for problems:  hyprctl configerrors ; hyprctl deprecated-config
  • Keybindings: see README.md
MSG
