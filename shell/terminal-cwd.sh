#!/usr/bin/env bash

# Print the working directory of whatever is running in the focused terminal
# (the shell itself at a prompt, or e.g. nvim if it's open). Falls back to $HOME.

pid=$(hyprctl activewindow -j | jq -r '.pid')
# kitty also spawns helper kittens with no tty (tpgid -1); skip those.
# tpgid = the terminal's foreground process: the shell itself at a prompt, or e.g. nvim if it's open
fg_pid=$(ps -o tpgid= --ppid "$pid" 2>/dev/null | awk '$1 > 0 {p=$1} END {print p}')
dir=$(readlink "/proc/$fg_pid/cwd" 2>/dev/null)

if [[ -d "$dir" ]]; then
    echo "$dir"
else
    echo "$HOME"
fi
