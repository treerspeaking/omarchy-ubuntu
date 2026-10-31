#!/usr/bin/env bash

makoctl list |
    awk '/^Notification /{id=$2+0} /App name: Hyprshot$/{print id}' |
    while read -r id; do
        makoctl dismiss -n "$id"
    done

exec "$HOME/.local/bin/hyprshot" "$@"
