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
    --nth "2"         # only fuzzy search the name field
    --tiebreak "chunk,begin,length"
    --tabstop 1 # render a tab as 1 space
    --preview 'case {1} in apt:*) dpkg -s {2} ;; flatpak:*) flatpak info {4} ;; esac'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

# Only list packages that are actually installed (status "?i"), this skips
# the "rc" ones that were removed but still have their config files around
list_apt() {
    dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\t${binary:Summary}\n' |
        awk -F'\t' '$1 ~ /^.i/ {printf "%-8s\t%-30s\t%s\t\t\n", "apt:", $2, $3}'
}

# Only list apps, the runtimes they pulled in are cleaned up with --unused below
list_flatpak() {
    flatpak list --columns=name,description,application,origin |
        awk -F'\t' '{printf "%-8s\t%-30s\t%s\t%s\t%s\n", "flatpak:", $1, $2, $3, $4}'
}

list_packages() {
    cat <(list_apt) <(list_flatpak)
}

picks=$(fzf "${fzf_args[@]}" < <(list_packages))

apt_pkgs=$(awk -F'\t' '$1 ~ /^apt:/ {print $2}' <<<"$picks")
flatpak_ids=$(awk -F'\t' '$1 ~ /^flatpak:/ {print $4}' <<<"$picks")

if [[ -n $apt_pkgs ]]; then
    ask_for_sudo
    echo "$apt_pkgs" | xargs sudo apt-get remove --purge -y
    sudo apt-get autoremove -y
fi

if [[ -n $flatpak_ids ]]; then
    echo "$flatpak_ids" | xargs flatpak uninstall --delete-data -y
    flatpak uninstall --unused -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
