#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../ask_sudo.sh"

#   | 1    | 2    | 3           |
#   | apt: | name | description |
fzf_args=(
    --multi
    --delimiter '\t'
    --nth "2"      # Only perform fuzzy on the name field
    --accept-nth 2 # only get the package name
    --tabstop 1    # render tab only as 1 space
    --tiebreak "chunk,begin,length"
    --preview 'dpkg -s {2}'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

# Only list packages that are actually installed (status "?i"), this skips
# the "rc" ones that were removed but still have their config files around
pkg_names=$(dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\t${binary:Summary}\n' |
    awk -F'\t' '$1 ~ /^.i/ {printf "apt:\t%-30s\t%s\n", $2, $3}' |
    fzf "${fzf_args[@]}")

if [[ -n $pkg_names ]]; then
    ask_for_sudo
    echo "$pkg_names" | xargs sudo apt-get remove --purge -y
    sudo apt-get autoremove -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
