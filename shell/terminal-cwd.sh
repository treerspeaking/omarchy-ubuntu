#!/usr/bin/env bash

# Print the working directory of whatever is running in the focused terminal
# (the shell itself at a prompt, or e.g. nvim if it's open). Falls back to $HOME.

pid=$(hyprctl activewindow -j | jq -r '.pid')
final_child_pid=$(pgrep -P "$pid" | tail -n 1)
dir=$(readlink "/proc/$final_child_pid/cwd" 2>/dev/null)
# tpgid = the terminal's foreground process: the shell itself at a prompt, or e.g. nvim if it's open
fg_pid=$(ps -o tpgid= -p "$final_child_pid" 2>/dev/null | tr -d ' ')
dir=$(readlink "/proc/$fg_pid/cwd" 2>/dev/null)

if [[ -d "$dir" ]]; then
    echo "$dir"
else
    echo "$HOME"
fi
