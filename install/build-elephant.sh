#!/usr/bin/env bash

# elephant is the backend data/action service walker needs running before it
# can launch anything - see install/build-walker.sh
install_dependency_ubuntu() {
    if ! command -v go &>/dev/null; then
        sudo apt-get install -y --no-install-recommends golang-go
    fi

    # qalc is used by the calc provider for unit conversion / calculations
    sudo apt-get install -y --no-install-recommends qalc
}

install_dependency_fedora() {
    # golang provides go; qalculate provides the qalc CLI used by the calc provider
    sudo dnf install -y --setopt=install_weak_deps=False golang qalculate
}

set -e

BUILD_DIR="${BUILD_DIR:-$HOME/omarchy_ubuntu}"

OMARCHY_UBUNTU_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROVIDER_DIR="$OMARCHY_UBUNTU_DIR/elephant/providers"

# Providers to build alongside the core service. Add/remove names from
# internal/providers/ in https://github.com/abenz1267/elephant as needed
# (e.g. "bluetooth", "windows", "unicode", "aptpackages").
PROVIDERS=(desktopapplications calc files clipboard symbols runner websearch menus)
. /etc/os-release
if [[ $ID == ubuntu || $ID_LIKE == *ubuntu* || $ID_LIKE == *debian* ]]; then
    install_dependency_ubuntu
elif [[ $ID == fedora || $ID_LIKE == *fedora* ]]; then
    install_dependency_fedora
fi

mkdir -p "$BUILD_DIR"
if [ ! -d "$BUILD_DIR/elephant" ]; then
    git clone https://github.com/abenz1267/elephant.git "$BUILD_DIR/elephant"
fi

cd "$BUILD_DIR/elephant"
git fetch --tags
# elephant and its providers must come from the same checkout to avoid a
# plugin/host ABI mismatch, so pin both to this tag below
git checkout "$(git tag --sort=-v:refname | head -n 1)"

export GOTOOLCHAIN=auto
make build
sudo install -Dm 755 cmd/elephant/elephant /usr/local/bin/elephant

mkdir -p "$PROVIDER_DIR"
for PROVIDER in "${PROVIDERS[@]}"; do
    echo "Building provider: $PROVIDER"
    (
        cd "internal/providers/$PROVIDER"
        # must match the GO_BUILD_FLAGS in the makefile's main binary build,
        # otherwise Go rejects the plugin at load time with an ABI mismatch
        # ("plugin was built with a different version of package internal/goarch")
        go build -buildvcs=false -trimpath -buildmode=plugin
        cp "$PROVIDER.so" "$PROVIDER_DIR/"
    )
done

elephant service enable
systemctl --user enable --now elephant.service

echo "elephant installed with providers: ${PROVIDERS[*]}"
