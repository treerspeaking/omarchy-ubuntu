#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OMARCHY_UBUNTU_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"/../ && pwd)
TEMP_DIR="$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/tmp"

if [[ ! -d "$TEMP_DIR" ]]; then
    mkdir -p "$TEMP_DIR"
fi

background_img_dir="${1#"$HOME"}"

ln -sfn "$1" "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/tmp/background-img"

printf "%s\n" "$background_img_dir" >"$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/tmp/current-background.name"

"$SCRIPT_DIR/move-theme-change.sh"

hyprctl hyprpaper wallpaper ",$(readlink -f "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/theme/background-img")"
