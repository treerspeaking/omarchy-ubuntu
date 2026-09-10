#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/ask_sudo.sh"

fzf_args=(
    --multi
    --nth "2"      # Only perform the filter on the second field separated by ' '
    --accept-nth 2 # Only get the 2 field separated by ' '
    --tiebreak "chunk,begin,length"
    --preview 'apt-cache show {2}'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

pkg_names=$(apt-cache search . | sed 's/^/apt: /' | fzf "${fzf_args[@]}")

if [[ -n $pkg_names ]]; then
    ask_for_sudo
    # Convert the newline to space separated
    echo "$pkg_names" | xargs sudo apt-get install -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
