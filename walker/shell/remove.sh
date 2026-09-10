#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/ask_sudo.sh"

pkg_names=$(dpkg-query -f '${binary:Package}\n' -W | fzf -m)

if [[ -n $pkg_names ]]; then
    ask_for_sudo
    echo "$pkg_names" | xargs sudo apt-get remove --purge -y
    sudo apt-get autoremove -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
