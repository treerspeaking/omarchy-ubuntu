#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../ask_sudo.sh"

#   | 1        | 2    | 3           | 4           | 5      |
#   | apt:     | name | description |             |        |
#   | flatpak: | name | description | application | origin |
fzf_args=(
    --multi
    --delimiter '\t'
    --with-nth "1..3" # show only fields 1-3
    --nth "2"         # only fuzzy search fields name
    --tiebreak "chunk,begin,length"
    --tabstop 1 # render a tab as 1 space
    --preview 'case {1} in apt:*) apt-cache show {2} ;; flatpak:*) flatpak remote-info {5} {4} ;; esac'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

list_apt() {
    apt-cache search . |
        awk '{pkg = $1; sub(/^[^ ]+ - /, ""); printf "%-8s\t%-30s\t%s\t\t\n", "apt:", pkg, $0}'
}

list_flatpak() {
    flatpak remote-ls --columns=name,description,application,origin |
        awk -F'\t' '{printf "%-8s\t%-30s\t%s\t%s\t%s\n", "flatpak:", $1, $2, $3, $4}'
}

list_packages() {
    cat <(list_apt) <(list_flatpak)
}

# Doing it like this will allow the user to select apt first and don't have to wait for flatpak to also finish searching
picks=$(fzf "${fzf_args[@]}" < <(list_packages))

apt_pkgs=$(awk -F'\t' '$1 ~ /^apt:/ {print $2}' <<<"$picks")
flatpak_ids=$(awk -F'\t' '$1 ~ /^flatpak:/ {print $4}' <<<"$picks")

if [[ -n $apt_pkgs ]]; then
    ask_for_sudo
    echo "$apt_pkgs" | xargs sudo apt-get install -y
fi

if [[ -n $flatpak_ids ]]; then
    echo "$flatpak_ids" | xargs flatpak install -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
