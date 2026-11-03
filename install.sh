#!/usr/bin/env bash
# Speedtest Gauge - installer for KDE Plasma 6
set -e

ID="req8939.speedtest"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin/ookla-speedtest"

if [ "$1" = "--uninstall" ]; then
    kpackagetool6 -t Plasma/Applet -r "$ID" || true
    echo "Widget removed. (Ookla CLI left at $BIN)"
    exit 0
fi

command -v kpackagetool6 >/dev/null || { echo "kpackagetool6 not found (is Plasma 6 installed?)"; exit 1; }

# 1. Widget
echo "==> Installing widget..."
kpackagetool6 -t Plasma/Applet -u "$DIR" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$DIR"

# Icon
mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps"
cp "$DIR/icon/speedtest-gauge.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/"

# 2. Ookla CLI
if [ -x "$BIN" ]; then
    echo "==> Ookla CLI already installed."
else
    case "$(uname -m)" in
        x86_64)  ARCH=x86_64 ;;
        aarch64) ARCH=aarch64 ;;
        *) echo "Unsupported architecture: $(uname -m). Install the Ookla CLI manually."; exit 1 ;;
    esac
    echo "==> Downloading Ookla Speedtest CLI ($ARCH)..."
    TMP="$(mktemp -d)"
    curl -fsSL "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$ARCH.tgz" -o "$TMP/st.tgz"
    tar xzf "$TMP/st.tgz" -C "$TMP" speedtest
    mkdir -p "$HOME/.local/bin"
    mv "$TMP/speedtest" "$BIN"
    rm -rf "$TMP"
    "$BIN" --accept-license --accept-gdpr -V >/dev/null 2>&1 || true
fi

echo
echo "Done! Right click the desktop > Add Widgets > 'Speedtest Gauge'."
echo "If it doesn't show up, run: kquitapp6 plasmashell; kstart plasmashell"
