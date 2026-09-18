#!/usr/bin/env bash

#   | 1        | 2    | 3           | 4           | 5      |
#   | flatpak: | name | description | application | origin |
fzf_args=(
    --multi
    --delimiter '\t'
    --with-nth "1..3" # show only 1-3 separated field
    --nth "2"         # Only perform fuzzy on the name field
    --accept-nth 4    # only get the flatpak id
    --tabstop 1       # render tab only as 1 space
    --tiebreak "chunk,begin,length"
    --preview 'flatpak remote-info {5} {4}'
    --preview-window 'down:65%:wrap:hidden'
    --header $'alt-p: toggle description'
    --preview-label 'alt-j/k: description-down/up, alt-d/u: description-half-page-down/up'
    --preview-label-pos='bottom'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up,alt-k:preview-up,alt-j:preview-down,alt-p:toggle-preview'
)

pkg_names=$(flatpak remote-ls --columns=name,description,application,origin |
    awk -F'\t' '{printf "flatpak:\t%-30s\t%s\t%s\t%s\n", $1, $2, $3, $4}' |
    fzf "${fzf_args[@]}")

if [[ -n $pkg_names ]]; then
    echo "$pkg_names" | xargs flatpak install -y
fi

read -rn 1 -s -p "Press any key..."

exit 0
