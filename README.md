# Speedtest Gauge

Plasma 6 widget that measures your internet speed with live animated gauges (download, upload, ping and server). Includes color themes and settings.

## Requirements
Official Ookla Speedtest CLI at `~/.local/bin/ookla-speedtest`:

    mkdir -p ~/.local/bin && cd /tmp
    curl -LO https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
    tar xzf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest
    mv speedtest ~/.local/bin/ookla-speedtest

## Install
    kpackagetool6 -t Plasma/Applet -i req8939.speedtest.plasmoid

## License
GPL-2.0-or-later
