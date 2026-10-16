#!/usr/bin/env bash

BUILD_DIR="$HOME/omarchy_ubuntu"
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

# ask for sudo

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

mkdir -p $BUILD_DIR
XDG_CONFIG_HOME="$HOME/.config"
SYSTEMD_USER_DIR="/usr/lib/systemd/user"
HYPR_CONF_DIR="$XDG_CONFIG_HOME/hypr"
mkdir -p "$HYPR_CONF_DIR"
HYPRLAND_CONF_FILE="$HYPR_CONF_DIR/hyprland.lua"
mkdir -p "$HOME/.local/bin"

echo "------------------------------------------------"
echo "Installing uwsm..."
echo "------------------------------------------------"

sudo dnf copr enable erikreider/swayosd -y
sudo dnf copr enable lionheartp/Hyprland -y

sudo dnf install uwsm hyprland-uwsm -y

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
    # This could probly be change later for dynamic theme change
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

sudo dnf install cargo -y
# Add cargo to path
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
    sudo dnf install bluez dbus-devel pkgconf-pkg-config pipewire-libs -y
    sudo systemctl enable --now bluetooth.service
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
if has_wifi || has_ethernet; then
    echo "Wi-Fi hardware detected. Installing wlctl..."
    cargo install wlctl
fi

sudo dnf install hyprland kitty hyprlauncher hyprcursor hyprland-guiutils hyprshutdown hyprpolkitagent \
    xdg-desktop-portal-hyprland mesa-dri-drivers -y

systemctl --user enable hyprpolkitagent.service

sudo dnf install wireplumber jq grim slurp wl-clipboard libnotify pamixer nautilus btop fzf \
    flatpak xdg-terminal-exec xdg-desktop-portal-gtk gnome-keyring qt6-qtwayland \
    wiremix google-noto-color-emoji-fonts adwaita-icon-theme bluez findutils \
    qalculate curl -y

if [[ $HYPRPAPER_SETUP == "true" ]]; then
    sudo dnf install hyprpaper -y
    systemctl --user enable hyprpaper.service
fi

if [[ $HYPRLOCK_SETUP == "true" ]]; then
    sudo dnf install hyprlock -y
fi

if [[ "$HYPRIDLE_SETUP" == "true" ]] && [[ "$HYPRLOCK_SETUP" == "true" ]]; then
    sudo dnf install hypridle -y
    systemctl --user enable hypridle.service
fi

if [[ $HYPRSHOT_SETUP == "true" ]]; then
    sudo dnf install hyprshot -y
fi

if [ "mako" = "$NOTIFICATION_DAEMON_PREF" ]; then
    sudo dnf install mako -y
    MAKO_CONFIG_DIR="$XDG_CONFIG_HOME/mako"
    mkdir -p "$MAKO_CONFIG_DIR"
    systemctl --user enable mako.service
fi

if [[ $SWAYOSD_SETUP == "true" ]]; then
    sudo dnf install brightnessctl playerctl swayosd -y

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
        sudo systemctl enable swayosd-libinput-backend.service
        # brightnessctl is still expecting video group membership
        sudo usermod -aG video "$USER"
    fi
fi

if [[ $WAYBAR_SETUP == "true" ]]; then
    sudo dnf install waybar -y
    WAYBAR_CONFIG_DIR="$XDG_CONFIG_HOME/waybar"
    mkdir -p "$WAYBAR_CONFIG_DIR"
fi

if [[ $WALKER_SETUP == "true" ]]; then
    BUILD_DIR="$BUILD_DIR" bash "$SCRIPT_DIR/build-elephant.sh"
    BUILD_DIR="$BUILD_DIR" bash "$SCRIPT_DIR/build-walker.sh"
fi

if [[ ! -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont" ]]; then
    sudo dnf install unzip -y
    bash "$SCRIPT_DIR/install-font.sh"
fi
# Point ~/.config at this repo's configs - any existing real dirs (including the
# ones generated above) are moved aside to <name>.bak.<timestamp> first
echo "------------------------------------------------"
echo "Symlinking configs into $XDG_CONFIG_HOME..."
echo "------------------------------------------------"
bash "$SCRIPT_DIR/make_symlink.sh"

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
