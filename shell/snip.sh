#!/usr/bin/env bash
# Could add this as a mako mode will probly do it later after reading the manual
makoctl list |
    awk '/^Notification /{id=$2+0} /App name: Hyprshot$/{print id}' |
    while read -r id; do
        makoctl dismiss -n "$id"
    done

exec "hyprshot" "$@"
