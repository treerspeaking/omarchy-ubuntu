#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/ask_sudo.sh"

# Every line has the same tab-separated fields:
# 1 source, 2 name, 3 description (flatpak), 4 description (apt),
# 5 app ID (flatpak), 6 origin (flatpak)
fzf_args=(
    --multi
    --delimiter '\t'
    --with-nth "1..4" # show only fields 1-4
    --nth "2,3"       # only fuzzy search fields 2 and 3 (empty on apt lines)
    --tiebreak "chunk,begin,length"
    --tabstop 1 # render a tab as 1 space
    --preview 'case {1} in apt:*) apt-cache show {2} ;; flatpak:*) flatpak remote-info {6} {5} ;; esac'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

list_apt() {
    apt-cache search . |
        awk '{pkg = $1; sub(/^[^ ]+ - /, ""); printf "%s\t%-29s\t\t%s\t\t\n", "apt:", pkg, $0}'
}

list_flatpak() {
    flatpak remote-ls --columns=name,description,application,origin |
        awk -F'\t' '{printf "%-8s\t%-30s\t%s\t\t%s\t%s\n", "flatpak:", $1, $2, $3, $4}'
}

list_packages() {
    cat <(list_apt) <(list_flatpak)
}

picks=$(list_packages | fzf "${fzf_args[@]}")

apt_pkgs=$(awk -F'\t' '$1 ~ /^apt:/ {print $2}' <<<"$picks")
flatpak_ids=$(awk -F'\t' '$1 ~ /^flatpak:/ {print $5}' <<<"$picks")

if [[ -n $apt_pkgs ]]; then
    ask_for_sudo
    echo "$apt_pkgs" | xargs sudo apt-get install -y
fi

if [[ -n $flatpak_ids ]]; then
    echo "$flatpak_ids" | xargs flatpak install -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
