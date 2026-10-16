#!/usr/bin/env bash

OMARCHY_UBUNTU_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"/../ && pwd)

# Maybe in the future add a flag to allow for back up the symlink too
set -e

if [[ -d "$HOME/.config/hypr" ]] && [[ ! -L "$HOME/.config/hypr" ]]; then
    mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/hypr" ~/.config/hypr

if [[ -d "$HOME/.config/waybar" ]] && [[ ! -L "$HOME/.config/waybar" ]]; then
    mv "$HOME/.config/waybar" "$HOME/.config/waybar.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/waybar" ~/.config/waybar

if [[ -d "$HOME/.config/elephant" ]] && [[ ! -L "$HOME/.config/elephant" ]]; then
    mv "$HOME/.config/elephant" "$HOME/.config/elephant.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/elephant" ~/.config/elephant

if [[ -d "$HOME/.config/walker" ]] && [[ ! -L "$HOME/.config/walker" ]]; then
    mv "$HOME/.config/walker" "$HOME/.config/walker.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/walker" ~/.config/walker

if [[ -e "$HOME/.local/share/applications/kitty.desktop" ]] && [[ ! -L "$HOME/.local/share/applications/kitty.desktop" ]]; then
    mv "$HOME/.local/share/applications/kitty.desktop" "$HOME/.local/share/applications/kitty.desktop.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/kitty/kitty.desktop" ~/.local/share/applications/kitty.desktop

if [[ -d "$HOME/.config/elephant" ]] && [[ ! -L "$HOME/.config/elephant" ]]; then
    mv "$HOME/.config/elephant" "$HOME/.config/elephant.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/elephant" ~/.config/elephant

if [[ -d "$HOME/.config/current-omarchy-ubuntu" ]] && [[ ! -L "$HOME/.config/current-omarchy-ubuntu" ]]; then
    mv "$HOME/.config/current-omarchy-ubuntu" "$HOME/.config/current-omarchy-ubuntu.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu" ~/.config/current-omarchy-ubuntu

mkdir -p "$HOME/.config/systemd/user/graphical-session.target.wants"

if [[ -e "$HOME/.config/systemd/user/graphical-session.target.wants/walker.service" ]] && [[ ! -L "$HOME/.config/systemd/user/graphical-session.target.wants/walker.service" ]]; then
    mv "$HOME/.config/systemd/user/graphical-session.target.wants/walker.service" "$HOME/.config/systemd/user/graphical-session.target.wants/walker.service.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/walker.service" ~/.config/systemd/user/graphical-session.target.wants/walker.service

if [[ -e "$HOME/.config/systemd/user/walker.service" ]] && [[ ! -L "$HOME/.config/systemd/user/walker.service" ]]; then
    mv "$HOME/.config/systemd/user/walker.service" "$HOME/.config/systemd/user/walker.service.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/walker.service" ~/.config/systemd/user/walker.service

if [[ -d "$HOME/.config/systemd/user/hyprpolkitagent.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/hyprpolkitagent.service.d" ]]; then
    mv "$HOME/.config/systemd/user/hyprpolkitagent.service.d" "$HOME/.config/systemd/user/hyprpolkitagent.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/hyprpolkitagent.service.d" ~/.config/systemd/user/hyprpolkitagent.service.d

if [[ -d "$HOME/.config/systemd/user/elephant.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/elephant.service.d" ]]; then
    mv "$HOME/.config/systemd/user/elephant.service.d" "$HOME/.config/systemd/user/elephant.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/elephant.service.d" ~/.config/systemd/user/elephant.service.d

if [[ -d "$HOME/.config/systemd/user/hypridle.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/hypridle.service.d" ]]; then
    mv "$HOME/.config/systemd/user/hypridle.service.d" "$HOME/.config/systemd/user/hypridle.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/hypridle.service.d" ~/.config/systemd/user/hypridle.service.d

if [[ -d "$HOME/.config/systemd/user/hyprpaper.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/hyprpaper.service.d" ]]; then
    mv "$HOME/.config/systemd/user/hyprpaper.service.d" "$HOME/.config/systemd/user/hyprpaper.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/hyprpaper.service.d" ~/.config/systemd/user/hyprpaper.service.d

if [[ -d "$HOME/.config/systemd/user/mako.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/mako.service.d" ]]; then
    mv "$HOME/.config/systemd/user/mako.service.d" "$HOME/.config/systemd/user/mako.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/mako.service.d" ~/.config/systemd/user/mako.service.d

if [[ -d "$HOME/.config/systemd/user/swayosd.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/swayosd.service.d" ]]; then
    mv "$HOME/.config/systemd/user/swayosd.service.d" "$HOME/.config/systemd/user/swayosd.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/swayosd.service.d" ~/.config/systemd/user/swayosd.service.d

if [[ -d "$HOME/.config/systemd/user/walker.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/walker.service.d" ]]; then
    mv "$HOME/.config/systemd/user/walker.service.d" "$HOME/.config/systemd/user/walker.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/walker.service.d" ~/.config/systemd/user/walker.service.d

if [[ -d "$HOME/.config/systemd/user/waybar.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/waybar.service.d" ]]; then
    mv "$HOME/.config/systemd/user/waybar.service.d" "$HOME/.config/systemd/user/waybar.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/waybar.service.d" ~/.config/systemd/user/waybar.service.d

if [[ -d "$HOME/.config/btop" ]] && [[ ! -L "$HOME/.config/btop" ]]; then
    mv "$HOME/.config/btop" "$HOME/.config/btop.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/btop" ~/.config/btop

mkdir -p "$HOME/.config/btop/themes"

ln -sfn "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/theme/btop.theme" ~/.config/btop/themes/current.theme

if [[ -d "$HOME/.config/mako" ]] && [[ ! -L "$HOME/.config/mako" ]]; then
    mv "$HOME/.config/mako" "$HOME/.config/mako.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/mako" ~/.config/mako
ln -sfn "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/theme/mako.ini" ~/.config/mako/config

if [[ -d "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d" ]] && [[ ! -L "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d" ]]; then
    mv "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d" "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/xdg-desktop-portal-gtk.service.d" ~/.config/systemd/user/xdg-desktop-portal-gtk.service.d

if [[ -e "$HOME/.config/systemd/user/graphical-session.target.wants/xdg-desktop-portal-gtk.service" ]] && [[ ! -L "$HOME/.config/systemd/user/graphical-session.target.wants/xdg-desktop-portal-gtk.service" ]]; then
    mv "$HOME/.config/systemd/user/graphical-session.target.wants/xdg-desktop-portal-gtk.service" "$HOME/.config/systemd/user/graphical-session.target.wants/xdg-desktop-portal-gtk.service.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn /usr/lib/systemd/user/xdg-desktop-portal-gtk.service ~/.config/systemd/user/graphical-session.target.wants/xdg-desktop-portal-gtk.service

if [[ ! -e "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/theme/background-img" ]]; then
    ln -sfn "$OMARCHY_UBUNTU_DIR/themes/ristretto/backgrounds/3-industrial-moon.jpg" "$OMARCHY_UBUNTU_DIR/current-omarchy-ubuntu/theme/background-img"
fi

if [[ -e "$HOME/.config/systemd/user/graphical-session.target.wants/swayosd.service" ]] && [[ ! -L "$HOME/.config/systemd/user/graphical-session.target.wants/swayosd.service" ]]; then
    mv "$HOME/.config/systemd/user/graphical-session.target.wants/swayosd.service" "$HOME/.config/systemd/user/graphical-session.target.wants/swayosd.service.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/swayosd.service" ~/.config/systemd/user/graphical-session.target.wants/swayosd.service

if [[ -e "$HOME/.config/systemd/user/swayosd.service" ]] && [[ ! -L "$HOME/.config/systemd/user/swayosd.service" ]]; then
    mv "$HOME/.config/systemd/user/swayosd.service" "$HOME/.config/systemd/user/swayosd.service.bak.$(date +%Y%m%d_%H%M%S)"
fi

ln -sfn "$OMARCHY_UBUNTU_DIR/systemd/swayosd.service" ~/.config/systemd/user/swayosd.service
