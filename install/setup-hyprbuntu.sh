#!/usr/bin/env bash
# Modified from https://gitlab.com/kralos/hyprbuntu/-/blob/main/setup-hyprbuntu.sh?ref_type=heads

set -e

# If you want to run this script non-interactively, set the following environment variables:
#
# BUILD_DIR="$HOME/hyprbuntu" - you can set the BUILD_DIR somewhere else if you want
# DISABLE_CONFIRM=false|true - disable the settings confirmation message
# HYPRIDLE_SETUP=true|false - whether to set up (minimal config) hypridle
# HYPRLOCK_SETUP=true|false - whether to install (without config) hyprlock
# HYPRPAPER_SETUP=true|false - whether to install (without config) hyprpaper
# HYPRSHOT_SETUP=true|false - whether to set up (minimal config) hyprshot
# NOTIFICATION_DAEMON_PREF=dunst|mako|swaync|none - whether to set up a notification daemon
# NVIDIA_SETUP=true|false - whether to set up nvidia proprietory drivers (ignored if no nvidia card is detected)
# SWAYOSD_SETUP=true|false - whether to set up (minimal config) swayosd
# THEME_PREF=dark|light|none - whether to set a default Adwaita theme
# THUNAR_SETUP=true|false - whether to set up thunar
# TUIGREET_SETUP=true|false - whether to set up tuigreet as the login manager
# WALKER_SETUP=true|false - whether to build walker + elephant (app launcher)
# WAYBAR_SETUP=true|false - whether to install (minimal config) waybar as the status bar
# KITTY_CONFIG_SETUP=true|false - whether to add include ~/.local/share/omarchy-ubuntu/current-omarchy-ubuntu/theme/kitty-theme.conf

BUILD_DIR="$HOME/hyprbuntu"
DISABLE_CONFIRM=false
HYPRIDLE_SETUP=true
HYPRLOCK_SETUP=true
HYPRPAPER_SETUP=true
HYPRSHOT_SETUP=true
NOTIFICATION_DAEMON_PREF=mako
NVIDIA_SETUP=false
SWAYOSD_SETUP=true
THEME_PREF=dark
TUIGREET_SETUP=false
WALKER_SETUP=true
WAYBAR_SETUP=true
KITTY_CONFIG_SETUP=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHY_CORES=$(lscpu -p=CORE,SOCKET | grep -v '^#' | sort -u | wc -l)
MAKE_THREADS=$((PHY_CORES > 1 ? PHY_CORES - 1 : 1))
ask_yes_no() {
    local PROMPT="$1"
    local VAR_NAME="$2"
    local DEFAULT_VAL="$3"

    if [[ -n "${!VAR_NAME}" ]]; then
        return
    fi

    if [[ "$DEFAULT_VAL" == "true" ]]; then
        read -p "$PROMPT [Y/n] " -r
    else
        read -p "$PROMPT [y/N] " -r
    fi
    if [[ $REPLY =~ ^[Nn] ]]; then
        printf -v "$VAR_NAME" "%s" "false"
    else
        printf -v "$VAR_NAME" "%s" "true"
    fi
}

apt_install() {
    if [ $# -eq 0 ]; then
        return
    fi

    echo "Installing apt dependencies: $*"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}
UPGRADES=()
install_hyprwm_package() {
    local PACKAGE_NAME="$1"
    local GIT_REF="$2" # A specific tag or branch, or "@stable" for latest tag
    shift 2
    local DEPS=("$@")
    echo "------------------------------------------------"
    echo "Installing hyprwm/$PACKAGE_NAME..."
    echo "------------------------------------------------"
    if [ ! -d "$BUILD_DIR/$PACKAGE_NAME" ]; then
        git clone --recursive "https://github.com/hyprwm/$PACKAGE_NAME.git" "$BUILD_DIR/$PACKAGE_NAME"
    fi
    cd "$BUILD_DIR/$PACKAGE_NAME"
    local OLD_REF=$(git rev-parse HEAD)
    local OLD_VERSION=$(git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    git fetch --all --tags --prune --recurse-submodules
    local LATEST_TAG=$(git tag --sort=-v:refname | head -n 1)
    local LATEST_REF=$(git rev-parse "$LATEST_TAG")
    if [ "@stable" = "$GIT_REF" ]; then
        if [ -z "$LATEST_TAG" ]; then
            echo "hyprwm/$PACKAGE_NAME has no tags"
            exit 1
        fi
        echo "Checking out latest tag: $LATEST_TAG"
        TARGET="$LATEST_TAG"
    else
        echo "Manual override: Checking out $GIT_REF"
        TARGET="$GIT_REF"
    fi
    git checkout "$TARGET"
    if git show-ref --verify --quiet "refs/remotes/origin/$TARGET"; then
        echo "Resetting branch $TARGET to remote state..."
        git reset --hard "origin/$TARGET"
    fi
    git submodule sync --recursive
    git submodule update --init --force --recursive
    local NEW_REF=$(git rev-parse HEAD)
    local NEW_VERSION=$(git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    if [ "$LATEST_REF" != "$NEW_REF" ]; then
        UPGRADES+=("hyprwm/$PACKAGE_NAME Built "$NEW_VERSION" although "$LATEST_TAG" is the latest")
    fi
    if [ "$OLD_REF" != "$NEW_REF" ]; then
        git clean -ffdx
        UPGRADES+=("hyprwm/$PACKAGE_NAME Upgraded $OLD_VERSION -> $NEW_VERSION")
    else
        git clean -ffdx -e build/
    fi
    git reset --hard HEAD
    git submodule foreach --recursive git reset --hard
    git submodule foreach --recursive git clean -ffdx
    if [ ${#DEPS[@]} -gt 0 ]; then
        apt_install "${DEPS[@]}"
    fi
    # Hyprland 0.56.0 uses std::ranges::starts_with (C++23), which only landed in
    # libstdc++ with GCC 16 (2026-04) - 26.04 defaults to GCC 15. Other hyprwm repos
    # are probably going to follow suit.
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC:-cc}" -DCMAKE_CXX_COMPILER="${CXX:-c++}" --fresh -B build
    cmake --build build -j $MAKE_THREADS
    sudo cmake --install build
}

# whoami

if [ "$EUID" -eq 0 ]; then
    echo "Error: Please run this script as your normal user, not directly as root or with sudo."
    echo "The script will ask for your sudo password when it needs to install packages."
    exit 1
fi
if ! sudo -v &>/dev/null; then
    echo "Error: You need sudo privileges to run this script."
    echo "Please ensure your user is in the sudo group/sudoers file."
    exit 1
fi

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# I have questions

apt_install pciutils
has_nvidia() {
    if lspci | grep -qi nvidia; then
        return 0 # true
    fi
    return 1 # false
}
if has_nvidia; then
    ask_yes_no "Would you like to install nvidia proprietory drivers" "NVIDIA_SETUP" "true"
fi

if [ -z "${THEME_PREF}" ]; then
    echo "Would you like to set a default base theme? (Adwaita)"
    echo "1) Dark Theme (Recommended)"
    echo "2) Light Theme"
    echo "3) None / Skip"
    read -p "Select an option [1-3, default 1]: " -r
    case $REPLY in
    2) THEME_PREF="light" ;;
    3) THEME_PREF="none" ;;
    *) THEME_PREF="dark" ;; # Default to dark
    esac
fi

if [ -z "${NOTIFICATION_DAEMON_PREF}" ]; then
    echo "Would you like to setup a notification daemon?"
    echo "1) dunst"
    echo "2) mako"
    echo "3) swaync (Recommended)"
    echo "4) None / Skip"
    read -p "Select an option [1-3, default 1]: " -r
    case $REPLY in
    1) NOTIFICATION_DAEMON_PREF="dunst" ;;
    2) NOTIFICATION_DAEMON_PREF="mako" ;;
    4) NOTIFICATION_DAEMON_PREF="none" ;;
    *) NOTIFICATION_DAEMON_PREF="swaync" ;; # Default to swaync
    esac
fi

ask_yes_no "Would you like to install hyprpaper" "HYPRPAPER_SETUP" "true"
ask_yes_no "Would you like to install hyprlock" "HYPRLOCK_SETUP" "true"
ask_yes_no "Would you like to install hypridle" "HYPRIDLE_SETUP" "true"
ask_yes_no "Would you like to install hyprshot" "HYPRSHOT_SETUP" "true"
ask_yes_no "Would you like to install swayosd (media keys/brightness)" "SWAYOSD_SETUP" "true"
ask_yes_no "Would you like to install thunar (GUI file explorer)" "THUNAR_SETUP" "true"
ask_yes_no "Would you like to install waybar (status bar)" "WAYBAR_SETUP" "true"
ask_yes_no "Would you like to build walker + elephant (app launcher, replaces hyprlauncher as the SUPER+SPACE default)" "WALKER_SETUP" "false"

has_tuigreet() {
    if command -v tuigreet &>/dev/null; then
        return 0 # true
    fi
    return 1 # false
}
ACTIVE_DESKTOP_MANAGER_SERVICES=()
DESKTOP_MANAGER_SERVICES=(
    gdm.service
    gdm3.service
    greetd.service
    lightdm.service
    lxdm.service
    ly.service
    sddm.service
    slim.service
    xdm.service
)
for SERVICE in "${DESKTOP_MANAGER_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SERVICE" || systemctl is-enabled --quiet "$SERVICE" 2>/dev/null; then
        ACTIVE_DESKTOP_MANAGER_SERVICES+=("$SERVICE")
    fi
done
has_desktop_manager() {
    if [ "${#ACTIVE_DESKTOP_MANAGER_SERVICES[@]}" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}
if has_tuigreet; then
    echo "tuigreet is already setup, skipping login manager setup"
    TUIGREET_SETUP=false
else
    if has_desktop_manager; then
        ACTIVE_DESKTOP_MANAGER_SERVICE_LIST=$(printf "%s\n" "${ACTIVE_DESKTOP_MANAGER_SERVICES[@]}")

        cat <<EOF
The following login manager(s) are active or enabled:

$ACTIVE_DESKTOP_MANAGER_SERVICE_LIST

If you want to use something else (e.g. tuigreet) you should remove your current desktop manager.
EOF
    else
        ask_yes_no "No desktop manager detected, would you like to setup tuigreet" "TUIGREET_SETUP" "true"
    fi
fi

if [ -z "${BUILD_DIR}" ]; then
    BUILD_DIR="$HOME/hyprbuntu"
fi

cat <<EOF

-----------------------------------------------
Hyprbuntu setup environment
-----------------------------------------------

NVIDIA_SETUP="$NVIDIA_SETUP"
THEME_PREF="$THEME_PREF"
NOTIFICATION_DAEMON_PREF="$NOTIFICATION_DAEMON_PREF"
HYPRPAPER_SETUP="$HYPRPAPER_SETUP"
HYPRLOCK_SETUP="$HYPRLOCK_SETUP"
HYPRIDLE_SETUP="$HYPRIDLE_SETUP"
HYPRSHOT_SETUP="$HYPRSHOT_SETUP"
SWAYOSD_SETUP="$SWAYOSD_SETUP"
THUNAR_SETUP="$THUNAR_SETUP"
WAYBAR_SETUP="$WAYBAR_SETUP"
WALKER_SETUP="$WALKER_SETUP"
TUIGREET_SETUP="$TUIGREET_SETUP"
BUILD_DIR="$BUILD_DIR"

EOF
if [[ "$DISABLE_CONFIRM" != "true" ]]; then
    read -p "Are you happy to continue with this configuration? [y/N] " -r
    if [[ ! $REPLY =~ ^[Yy] ]]; then
        echo "Aborting setup..."
        exit 0
    fi
fi

# ok no more questions

mkdir -p $BUILD_DIR
XDG_CONFIG_HOME="$HOME/.config"
SYSTEMD_USER_DIR="/usr/lib/systemd/user"
HYPR_CONF_DIR="$XDG_CONFIG_HOME/hypr"
mkdir -p "$HYPR_CONF_DIR"
HYPRLAND_CONF_FILE="$HYPR_CONF_DIR/hyprland.lua"
mkdir -p "$HOME/.local/bin"

sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y universe
sudo DEBIAN_FRONTEND=noninteractive apt-get update

apt_install \
    build-essential \
    cmake \
    cmake-extras \
    git \
    ninja-build \
    pkg-config \
    gcc-16 \
    g++-16 \
    curl

apt_install \
    fontconfig \
    fonts-adwaita \
    fonts-font-awesome \
    fonts-noto-color-emoji

fc-cache -fv

apt_install \
    adwaita-icon-theme \
    gsettings-desktop-schemas

apt_install \
    gnome-keyring \
    libpam-gnome-keyring \
    qt6-wayland \
    qtwayland5 \
    rtkit

UWSM_ENV_DIR="$XDG_CONFIG_HOME/uwsm"
if [ ! -d "$UWSM_ENV_DIR" ]; then
    mkdir -p "$UWSM_ENV_DIR"
fi
UWSM_ENV_FILE="$UWSM_ENV_DIR/env"
touch "$UWSM_ENV_FILE"
envs=(
    "export PATH=\"\${HOME}/.cargo/bin:\${PATH}\""
    "export QT_AUTO_SCREEN_SCALE_FACTOR=1"
    "export QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
    "export QT_QPA_PLATFORM=\"wayland;xcb\""
    "export QT_QPA_PLATFORMTHEME=qt6ct"
    "export ELECTRON_OZONE_PLATFORM_HINT=auto"
    "export XDG_PICTURES_DIR=\${HOME}/Pictures"
    "export HYPRSHOT_DIR=\${HOME}/Pictures/Screenshots"
    "export SSH_AUTH_SOCK=\${XDG_RUNTIME_DIR}/gcr/ssh"
)
echo "Checking environment variables in $UWSM_ENV_FILE..."
for LINE in "${envs[@]}"; do
    VARNAME=$(echo "$LINE" | sed -E 's/^export ([^= ]+)=.*/\1/')
    if ! grep -qF "$VARNAME" "$UWSM_ENV_FILE"; then
        echo "$LINE" >>"$UWSM_ENV_FILE"
        echo "  + Added missing $VARNAME"
    else
        echo "  . $VARNAME already set"
    fi
done

# uwsm is installed unconditionally: Hyprland's own build always ships a
# wayland-sessions/hyprland-uwsm.desktop entry that TryExec's uwsm, so
# without it that session silently disappears from the login manager's list.
echo "------------------------------------------------"
echo "Installing uwsm..."
echo "------------------------------------------------"
apt_install \
    meson \
    ninja-build \
    python3-setuptools \
    python3-xdg \
    scdoc

if [ ! -d "$BUILD_DIR/uwsm" ]; then
    git clone https://github.com/Vladimir-csp/uwsm.git "$BUILD_DIR/uwsm"
fi
(
    cd "$BUILD_DIR/uwsm"
    git fetch -p
    git checkout $(git tag --sort=-v:refname | head -n 1)
    meson setup build --prefix=/usr --libdir=lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH) -Duwsm-app=enabled
    sudo meson install -C build
)

if [ "none" != "$THEME_PREF" ]; then
    echo "Setting up $THEME_PREF theme..."

    THEME_NAME="Adwaita"
    if [ "light" = "$THEME_PREF" ]; then
        GTK_THEME_VAL="$THEME_NAME"
        COLOR_SCHEME="default"
        PREFER_DARK=0
    else
        GTK_THEME_VAL="$THEME_NAME:dark"
        COLOR_SCHEME="prefer-dark"
        PREFER_DARK=1
    fi

    theme_envs=(
        "export GTK_THEME=$GTK_THEME_VAL"
        "export HYPRCURSOR_SIZE=24"
        "export HYPRCURSOR_THEME=$THEME_NAME"
        "export XCURSOR_SIZE=24"
        "export XCURSOR_THEME=$THEME_NAME"
    )
    for LINE in "${theme_envs[@]}"; do
        VARNAME=$(echo "$LINE" | sed -E 's/^export ([^= ]+)=.*/\1/')
        if grep -q "^export $VARNAME=" "$UWSM_ENV_FILE"; then
            sed -i "s|^export $VARNAME=.*|$LINE|" "$UWSM_ENV_FILE"
            echo " -+ Overwrote $VARNAME"
        else
            echo "$LINE" >>"$UWSM_ENV_FILE"
            echo "  + Added $VARNAME"
        fi
    done

    GTK3_SETTINGS_DIR="$XDG_CONFIG_HOME/gtk-3.0"
    GTK4_SETTINGS_DIR="$XDG_CONFIG_HOME/gtk-4.0"
    mkdir -p "$GTK3_SETTINGS_DIR" "$GTK4_SETTINGS_DIR"
    cat <<EOF >"$GTK4_SETTINGS_DIR/settings.ini"
[Settings]
gtk-application-prefer-dark-theme=$PREFER_DARK
gtk-theme-name=$GTK_THEME_VAL
gtk-icon-theme-name=$THEME_NAME
gtk-cursor-theme-name=$THEME_NAME
EOF
    cp "$GTK4_SETTINGS_DIR/settings.ini" "$GTK3_SETTINGS_DIR/settings.ini"

    dbus-run-session bash <<EOF
gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-theme "$THEME_NAME"
EOF
fi

if [[ $NVIDIA_SETUP == "true" ]]; then
    echo "Installing propritetory nvidia drivers"
    sudo ubuntu-drivers install
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nvidia-vaapi-driver

    if ! grep -q "nvidia" "$UWSM_ENV_FILE"; then
        cat <<'EOF' >>"$UWSM_ENV_FILE"
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVD_BACKEND=direct
export MOZ_DISABLE_RDD_SANDBOX=1
EOF
    fi
fi

apt_install cargo
if ! grep -qF .cargo "$HOME/.bashrc"; then
    cat <<'EOF' >>"$HOME/.bashrc"

if [ -d "$HOME/.cargo/bin" ] ; then
PATH="$HOME/.cargo/bin:$PATH"
fi

EOF
fi

has_bluetooth() {
    modprobe -q btusb

    if [ -d /sys/class/bluetooth ] && [ -n "$(ls /sys/class/bluetooth)" ]; then
        return 0 # true
    fi

    return 1 # false
}
if has_bluetooth; then
    echo "Bluetooth hardware detected. Installing bluez and bluetui..."
    apt_install \
        bluez \
        libdbus-1-dev \
        libspa-0.2-bluetooth

    cargo install bluetui
fi

has_ethernet() {
    if ip link show | grep -q ' en'; then
        return 0 # true
    fi
    return 1 # false
}

has_wifi() {
    for IFACE in /sys/class/net/*; do
        if [ -d "$IFACE/wireless" ] || [ -d "$IFACE/phy80211" ]; then
            return 0 # true
        fi
    done
    return 1 # false
}
if has_wifi; then
    echo "Wi-Fi hardware detected. Installing wlctl..."
    cargo install wlctl
fi

has_battery() {
    if ls /sys/class/power_supply/BAT* 1>/dev/null 2>&1; then
        return 0 # true
    fi
    return 1 # false
}

# Move this up so wayland will be build before hyprland
# libre2 needs to be built from source as 26.04's libre2-dev package is too old (checked 2026-02-19)
# we should try checking apt again later by replacing this block with libre2-dev in the Hyprland deps below
echo "------------------------------------------------"
echo "Installing re2 from source..."
echo "------------------------------------------------"
# re2's find_package(absl) needs libabsl-dev. It used to arrive as one of hyprwire's
# apt deps, but this block now runs before any hyprwm package is built.
apt_install libabsl-dev
mkdir -p "$BUILD_DIR/re2"
(
    cd "$BUILD_DIR/re2"
    if [ ! -d .git ]; then
        git clone https://github.com/google/re2.git .
    fi
    git fetch
    git checkout $(git tag | sort -n | tail -1)
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_CXX_STANDARD=20 -DBUILD_SHARED_LIBS=ON -B build
    cmake --build build -j $(nproc)
    sudo cmake --install build
)

# wayland (core) needs to be built from source as 26.04's wayland-scanner (1.24.0) has
# a stale built-in protocol DTD, and wayland-protocols' own build uses --strict, which
# turns that DTD mismatch into a hard build failure (checked 2026-07-21)
echo "------------------------------------------------"
echo "Installing wayland from source..."
echo "------------------------------------------------"
mkdir -p "$BUILD_DIR/wayland"
(
    cd "$BUILD_DIR/wayland"
    if [ ! -d .git ]; then
        git clone https://gitlab.freedesktop.org/wayland/wayland.git .
    fi
    git fetch
    git checkout $(git tag | sort -V | tail -1)
    rm -rf build
    apt_install meson ninja-build libexpat1-dev libffi-dev libxml2-dev
    meson setup build --prefix=/usr/local -Dtests=false -Ddocumentation=false
    ninja -C build
    sudo ninja -C build install
)

# wayland-protocols needs to be built from source as 26.04's wayland-protocols package is too old (checked 2026-07-21)
# we should try checking apt again later by replacing this block with wayland-protocols in the Hyprland deps below
echo "------------------------------------------------"
echo "Installing wayland-protocols from source..."
echo "------------------------------------------------"
mkdir -p "$BUILD_DIR/wayland-protocols"
(
    cd "$BUILD_DIR/wayland-protocols"
    if [ ! -d .git ]; then
        git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git .
    fi
    git fetch
    git checkout $(git tag | sort -V | tail -1)
    rm -rf build
    apt_install meson ninja-build
    meson setup build --prefix=/usr/local -Dtests=false
    ninja -C build
    sudo ninja -C build install
)

install_hyprwm_package hyprwayland-scanner "@stable" \
    libpugixml-dev

install_hyprwm_package hyprutils "@stable" \
    libpixman-1-dev

install_hyprwm_package hyprland-protocols "main"

install_hyprwm_package hyprlang "@stable"

install_hyprwm_package hyprcursor "@stable" \
    libcairo2-dev \
    librsvg2-dev \
    libtomlplusplus-dev \
    libzip-dev

install_hyprwm_package hyprgraphics "@stable" \
    libdrm-dev \
    libgles2-mesa-dev \
    libheif-dev \
    libjpeg-dev \
    libjxl-dev \
    libmagic-dev \
    libwebp-dev

install_hyprwm_package aquamarine "@stable" \
    libdisplay-info-dev \
    libgbm-dev \
    libgles-dev \
    libinput-dev \
    libseat-dev \
    libwayland-dev \
    wayland-protocols

install_hyprwm_package hyprwire "@stable" \
    libabsl-dev

install_hyprwm_package hyprtoolkit "@stable" \
    libiniparser-dev \
    libxkbcommon-dev

install_hyprwm_package hyprland-guiutils "@stable"

install_hyprwm_package hyprpolkitagent "@stable" \
    libpolkit-agent-1-dev \
    libpolkit-qt6-1-dev \
    qml6-module-org-hyprland-style \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qt6-base-dev \
    qt6-declarative-dev

XDG_RUNTIME_DIR="/run/user/$(id -u)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" systemctl --user enable hyprpolkitagent.service

install_hyprwm_package xdg-desktop-portal-hyprland "@stable" \
    libpipewire-0.3-dev \
    libspa-0.2-dev \
    libsystemd-dev

mkdir -p "$XDG_CONFIG_HOME/xdg-desktop-portal"
if [ ! -f "$XDG_CONFIG_HOME/xdg-desktop-portal/portals.conf" ]; then
    cat <<'EOF' >"$XDG_CONFIG_HOME/xdg-desktop-portal/portals.conf"
[preferred]
default=hyprland;gtk
EOF
fi

CC=gcc-16 CXX=g++-16 install_hyprwm_package Hyprland "@stable" \
    glslang-dev \
    glslang-tools \
    libeis-dev \
    libglaze-dev \
    liblua5.5-dev \
    libmuparser-dev \
    libudis86-dev \
    libxcb-composite0-dev \
    libxcb-errors-dev \
    libxcb-icccm4-dev \
    libxcb-res0-dev \
    libxcb-xfixes0-dev \
    libxcursor-dev \
    libxkbcommon-dev

install_hyprwm_package hyprlauncher "@stable" \
    libqalculate-dev

if [[ $WALKER_SETUP == "true" ]]; then
    BUILD_DIR="$BUILD_DIR" bash "$SCRIPT_DIR/build-elephant.sh"
    BUILD_DIR="$BUILD_DIR" bash "$SCRIPT_DIR/build-walker.sh"
fi

if [[ ! -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont" ]]; then
    apt_install unzip
    bash "$SCRIPT_DIR/install-font.sh"
fi

bash "$SCRIPT_DIR/build-wiremix.sh"
bash "$SCRIPT_DIR/install-btop.sh"

install_hyprwm_package hyprshutdown "@stable"

if [[ $HYPRPAPER_SETUP == "true" ]]; then
    install_hyprwm_package hyprpaper "@stable"
    systemctl --user enable hyprpaper.service
fi

if [[ $HYPRLOCK_SETUP == "true" ]]; then
    install_hyprwm_package hyprlock "@stable" \
        libaudit-dev \
        libpam0g-dev \
        libsdbus-c++-dev

fi

if [[ "$HYPRIDLE_SETUP" == "true" ]] && [[ "$HYPRLOCK_SETUP" == "true" ]]; then
    install_hyprwm_package hypridle "@stable"
    systemctl --user enable hypridle.service
fi

if [ "mako" = "$NOTIFICATION_DAEMON_PREF" ]; then
    apt_install mako-notifier
    MAKO_CONFIG_DIR="$XDG_CONFIG_HOME/mako"
    mkdir -p "$MAKO_CONFIG_DIR"
    systemctl --user enable mako.service
fi

if [[ $HYPRSHOT_SETUP == "true" ]]; then
    apt_install \
        grim \
        slurp

    if [ ! -f "$HOME/.local/bin/hyprshot" ]; then
        # see XDG_PICTURES_DIR / HYPRSHOT_DIR envs
        mkdir -p "$HOME/Pictures/Screenshots"
        curl -o "$HOME/.local/bin/hyprshot" https://raw.githubusercontent.com/Gustash/Hyprshot/refs/heads/main/hyprshot
        chmod 755 "$HOME/.local/bin/hyprshot"
    fi
fi

if [[ $SWAYOSD_SETUP == "true" ]]; then
    apt_install \
        brightnessctl \
        playerctl \
        swayosd

    SWAY_UNIT_FILE="$SYSTEMD_USER_DIR/swayosd.service"
    if [ ! -f "$SWAY_UNIT_FILE" ]; then
        sudo tee "$SWAY_UNIT_FILE" >/dev/null <<'EOF'
[Unit]
Description=Volume/Backlight OSD Indicator
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/swayosd-server
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF
        systemctl --user daemon-reload
        systemctl --user enable swayosd.service
        # brightnessctl is still expecting video group membership
        sudo usermod -aG video $USER
    fi
fi

apt_install \
    alsa-ucm-conf \
    alsa-utils \
    at-spi2-core \
    kitty \
    libmtp-runtime \
    libnotify-bin \
    libspa-0.2-libcamera \
    pipewire \
    pipewire-audio-client-libraries \
    pipewire-pulse \
    upower \
    usbutils \
    wireplumber \
    wl-clipboard \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xwayland

if [[ $WAYBAR_SETUP == "true" ]]; then
    apt_install \
        waybar \
        wlogout

    WAYBAR_CONFIG_DIR="$XDG_CONFIG_HOME/waybar"
    mkdir -p "$WAYBAR_CONFIG_DIR"
fi

# Point ~/.config at this repo's configs - any existing real dirs (including the
# ones generated above) are moved aside to <name>.bak.<timestamp> first
echo "------------------------------------------------"
echo "Symlinking configs into $XDG_CONFIG_HOME..."
echo "------------------------------------------------"
bash "$SCRIPT_DIR/make_symlink.sh"

if [ -f /etc/netplan/00-installer-config.yaml ]; then
    sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.disabled
fi
apt_install network-manager
sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge networkd-dispatcher
if [[ ! -f /etc/netplan/01-network-manager-all.yaml ]]; then
    sudo tee /etc/netplan/01-network-manager-all.yaml >/dev/null <<'EOF'
network:
  version: 2
  renderer: NetworkManager
EOF
    sudo chmod 600 /etc/netplan/01-network-manager-all.yaml
    sudo netplan generate
    sudo netplan apply
fi
# We don't want to wait for network on boot
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

if [[ $KITTY_CONFIG_SETUP == "true" ]]; then
    line='include ~/.local/share/omarchy-ubuntu/current-omarchy-ubuntu/theme/kitty-theme.conf'
    # Create the kitty config if it does not exist
    mkdir -p "$HOME/.config/kitty"
    if ! grep -qxF "$line" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
        printf '\n%s\n' "$line" >>~/.config/kitty/kitty.conf
    fi
fi

cat <<EOF

-------------------------
Hyprbuntu setup complete!
-------------------------

EOF
if [ ${#UPGRADES[@]} -gt 0 ]; then
    echo "Upgrades"
    echo "-------------------------"
    for upgrade in "${UPGRADES[@]}"; do
        echo "$upgrade"
    done
    echo "-------------------------"
    echo
fi
cat <<EOF
We installed thunar (file explorer) instead of hyprland's default (dolphin) because it requires a heap of bloaty kde components
Once you start Hyprland, you will be greeted with the hyprland welcome app
You need to select "thunar" when asked (or fix this later by swapping "dolphin" for "thunar" in "$HYPRLAND_CONF_FILE")
If you prefer to swap out any components you can install replacements and re-configure "$HYPRLAND_CONF_FILE"
If you want to set environmental variables see "$UWSM_ENV_FILE"
If you are not using greetd / tuigreet from this script, I would highly recommend using a another uwsm based desktop manager.

Please reboot to start using Hyprland.

After you get into Hyprland check out the following commands:

- wiremix (audio)
- nmtui (network)
EOF
if has_wifi; then
    cat <<'EOF'
- wlctl (wifi)
EOF
fi
if has_bluetooth; then
    cat <<'EOF'
- bluetui (bluetooth)
EOF
fi
if [[ $THUNAR_SETUP == "true" ]]; then
    cat <<'EOF'
- thunar (file explorer)
EOF
fi
echo
if [[ $WALKER_SETUP == "true" ]]; then
    cat <<EOF
We've built walker + elephant (app launcher). elephant.service is enabled and running,
but walker itself needs to be bound to a key - set menu = "walker" in "$HYPRLAND_CONF_FILE"
to make it the SUPER+SPACE default (it currently points at hyprlauncher).

EOF
fi
if [[ $NVIDIA_SETUP == "true" ]]; then
    cat <<'EOF'
We've installed proprietory nvidia drivers
and added some configuration for you (see ~/.config/uwsm/env)

EOF
fi
if ! has_desktop_manager && [[ $TUIGREET_SETUP != "true" ]]; then
    cat <<'EOF'
We didn't install tuigreet for you.
You should start Hyprland with uwsm for all environmental variables and user services to work properly.

EOF
fi
cat <<EOF
You should have a look at your config in $XDG_CONFIG_HOME to start your ricing journey.
This script will not overwrite any config changes you make, you can run it multiple times to upgrade hyprland.

-------------------------
EOF
