#!/usr/bin/env bash
# An Omarchy-style nested menu built on `walker --dmenu`

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BACK="󰌍  Back"

# ---------------------------------------------------------------- helpers ---

# strip <pango markup> and any leading icon glyphs / whitespace from a label,
# so "󰔎  Style" matches the plain string "Style" in a case statement.
strip() {
    sed -E 's/<[^>]+>//g; s/^[^[:alnum:]]*//; s/[[:space:]]+$//' <<<"$1"
}

# menu <prompt> <entry> [entry...]
# Prints the cleaned selection. Exits the whole script if the user hits Esc.
menu() {
    local prompt="$1"
    shift
    local choice
    # --theme is optional; see the styling note at the bottom of this file.
    choice=$(printf '%s\n' "$@" | walker --dmenu --minheight 1 --maxheight 600 --minwidth 260 --maxwidth 260 -p "$prompt" 2>/dev/null) || exit 0
    [[ -z $choice ]] && exit 0
    strip "$choice"
}

# run something detached so the menu process doesn't hold the app open
launch() { uwsm-app -- "$@" 2>/dev/null || setsid "$@" & }

# open a TUI in a floating terminal (adjust to your terminal of choice)
# tui() { launch kitty --class=Tui -e "$@"; }
tui() {
    xdg-terminal-exec --app-id=floating.terminal "$@"
}

# ------------------------------------------------------------------ menus ---

show_main() {
    case $(
        menu "Menu" \
            "󰀻  Apps" \
            "󰔎  Style" \
            "  System" \
            "󰐥  Power" \
            "󰉉  Install" \
            "󰭌  Remove" \
            "󰉁  Keybind"
    ) in
    Apps) appmenu ;;
    Style) show_style ;;
    System) show_system ;;
    Power) show_power ;;
    Install) show_install ;;
    Remove) remove ;;
    Keybind) keybind ;;
    esac
}

show_style() {
    case $(menu "Style" \
        "󰸌  Theme" \
        "󰋩  Background" \
        "$BACK") in
    # these open Walker's own selectors rather than a dmenu list
    Theme) walker -m menus:omarchythemes --width 800 --minheight 400 ;;
    Background) walker -m menus:BackgroundThemeSelector --maxheight 400 --minwidth 260 --maxwidth 260 ;;
    Back) show_main ;;
    esac
}

show_system() {
    case $(
        menu "System" \
            "󰖩  Network" \
            "󰂯  Bluetooth" \
            "󰕾  Volume" \
            "󰍛  Btop" \
            "$BACK"
    ) in
    Network) tui wlctl ;;
    Bluetooth) tui bluetui ;;
    Volume) tui wiremix ;;
    Btop) tui btop ;;
    Back) show_main ;;
    esac
}

show_power() {
    case $(menu "Power" \
        "󰌾  Lock" \
        "󰍃  Logout" \
        "󰤄  Suspend" \
        "󰒲  Hibernate" \
        "󰜉  Restart" \
        "󰐥  Shutdown" \
        "$BACK") in
    Lock) hyprlock ;;
    Logout) hyprctl dispatch 'hl.dsp.exit()' ;;
    Suspend) systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Restart) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
    Back) show_main ;;
    esac
}

show_install() {
    case $(menu "Install" \
        "󰉉  Install all" \
        "  Install apt" \
        "󰓜  Install Flatpak" \
        "$BACK") in
    "Install all") tui "$SCRIPT_DIR/install.sh" ;;
    "Install apt") tui "$SCRIPT_DIR/install-apt.sh" ;;
    "Install Flatpak") tui "$SCRIPT_DIR/install-flatpak.sh" ;;
    Back) show_main ;;
    esac
}

appmenu() {
    "$SCRIPT_DIR/appmenu.sh"
}

install() {
    tui "$SCRIPT_DIR/install-apt.sh"
}

remove() {
    tui "$SCRIPT_DIR/remove.sh"
}

keybind() {
    "$SCRIPT_DIR/show-keybinds.sh"
}

change-theme() {
    "$SCRIPT_DIR/change-theme.sh"
}

toggle_existing_menu() {
    if pgrep -f "walker.*--dmenu" >/dev/null; then
        walker --close >/dev/null 2>&1
        exit 0
    fi
}

# --------------------------------------------------------------- dispatch ---

toggle_existing_menu

show_main
