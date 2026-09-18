#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../ask_sudo.sh"

#   | 1    | 2    | 3           |
#   | apt: | name | description |
fzf_args=(
    --multi
    --delimiter '\t'
    --nth "2"      # Only perform the filter on the name field
    --accept-nth 2 # Only get the name field
    --tabstop 1
    --tiebreak "chunk,begin,length"
    --preview 'apt-cache show {2}'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)
#

pkg_names=$(apt-cache search . | awk '{pkg = $1; sub(/^[^ ]+ - /, ""); printf "apt:\t%-30s\t%s\n", pkg, $0}' | fzf "${fzf_args[@]}")

if [[ -n $pkg_names ]]; then
    ask_for_sudo
    # Convert the newline to space separated
    echo "$pkg_names" | xargs sudo apt-get install -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
