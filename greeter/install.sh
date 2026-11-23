#!/bin/sh
# Installs the Dune greeter system-wide. Run:  sudo sh ~/.config/hypr/greeter/install.sh
# Undo:  sudo cp /etc/greetd/config.toml.pre-dune /etc/greetd/config.toml
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
DST=/usr/local/share/dune-greeter
install -d "$DST"
install -m 644 "$SRC/shell.qml" "$SRC/wallpaper.jpg" "$DST/"
# fonts must be visible to the greeter user
install -d /usr/local/share/fonts/dune
install -m 644 /home/gopal/.local/share/fonts/dune/*.ttf /usr/local/share/fonts/dune/
fc-cache -f >/dev/null 2>&1 || true
[ -f /etc/greetd/config.toml.pre-dune ] || cp /etc/greetd/config.toml /etc/greetd/config.toml.pre-dune
sed -i 's|^command = .*|command = "env DUNE_GREETER_USER=gopal /usr/bin/dms-greeter --command niri --shell-dir /usr/local/share/dune-greeter --cache-dir /var/cache/dms-greeter"|' /etc/greetd/config.toml
echo "done — takes effect at next logout/reboot. Rollback: cp /etc/greetd/config.toml.pre-dune /etc/greetd/config.toml"
