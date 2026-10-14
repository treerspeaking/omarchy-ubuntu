This is my opinionated Hyprland config which use Omarchy's theme.

[Demo](https://github.com/user-attachments/assets/f771d6ec-e105-429f-9dc5-c2b711b4589c)

# Install

```bash
sudo apt-get install git -y
git clone https://github.com/treerspeaking/omarchy-ubuntu ~/.local/share/omarchy-ubuntu
cd ~/.local/share/omarchy-ubuntu
bash install/setup-hyprbuntu.sh
```

## Optional

### Change the default programs

The apps the keybinds launch are plain globals at the top of
[`hypr/hyprland.lua`](hypr/hyprland.lua):

```lua
-- Set programs that you use
Terminal = "kitty"
FileManager = "nautilus"
Browser = "brave-browser"
```

# How to use

Some of the most important shortcut

| HotKey                  | Function          |
| ----------------------- | ----------------- |
| `Super + Space`         | App menu          |
| `Super + ALT + Space`   | menu              |
| `Super + SHIFT + ALT K` | Keybinds menu     |
| `Super + Enter`         | Open Kitty        |
| `Super + SHIFT + B`     | Open Browser      |
| `Super + SHIFT + F`     | Open file manager |

## Apps and menus

| HotKey                  | Function          |
| ----------------------- | ----------------- |
| `Super + Enter`         | Open Kitty        |
| `Super + SHIFT + B`     | Open browser      |
| `Super + SHIFT + F`     | Open file manager |
| `Super + Space`         | App menu          |
| `Super + ALT + Space`   | Menu              |
| `Super + K`             | Keybinds menu     |
| `Super + SHIFT + Space` | Toggle Waybar     |

## Windows

| HotKey                      | Function               |
| --------------------------- | ---------------------- |
| `Super + W`                 | Close active window    |
| `Super + T`                 | Toggle floating        |
| `Super + F`                 | Toggle fullscreen      |
| `Super + ALT + F`           | Toggle maximized       |
| `Super + P`                 | Toggle pseudotiling    |
| `Super + J`                 | Toggle split direction |
| `Super + SHIFT + Backspace` | Toggle window border   |
| `Super + ←/↑/↓/→`           | Move focus             |
| `Super + SHIFT + ←/↑/↓/→`   | Swap window            |
| `Super + Left mouse drag`   | Move window            |
| `Super + Right mouse drag`  | Resize window          |

## Workspaces

| HotKey                    | Function                      |
| ------------------------- | ----------------------------- |
| `Super + 1..9, 0`         | Switch to workspace 1-10      |
| `Super + SHIFT + 1..9, 0` | Move window to workspace      |
| `Super + Scroll`          | Switch to next/prev workspace |
| `Super + S`               | Toggle scratchpad             |
| `Super + ALT + SHIFT + S` | Move window to scratchpad     |

## Screenshots

| HotKey              | Function           |
| ------------------- | ------------------ |
| `Print`             | Region screenshot  |
| `ALT + Print`       | Window screenshot  |
| `SHIFT + Print`     | Monitor screenshot |
| `Super + SHIFT + S` | Region screenshot  |

## Notifications

| HotKey              | Function                  |
| ------------------- | ------------------------- |
| `Super + ,`         | Dismiss last notification |
| `Super + SHIFT + ,` | Dismiss all notifications |
| `Super + CTRL + ,`  | Restore last notification |
| `Super + ALT + ,`   | Toggle do not disturb     |

## Media and hardware keys

| HotKey                   | Function                 |
| ------------------------ | ------------------------ |
| `Volume Up` / `Down`     | Raise / lower volume     |
| `Mute`                   | Toggle mute              |
| `Mic Mute`               | Toggle microphone mute   |
| `Brightness Up` / `Down` | Raise / lower brightness |
| `Play` / `Pause`         | Play / pause media       |
| `Next` / `Previous`      | Next / previous track    |

# Credits

[Omarchy](https://github.com/basecamp/omarchy)
[kralos/hyprbuntu](https://gitlab.com/kralos/hyprbuntu)

# License

This config is released under the [MIT License](LICENSE).

`themes/` is vendored from [Omarchy](https://github.com/basecamp/omarchy),
which is also MIT licensed. Its copyright notice is kept at
[`themes/LICENSE`](themes/LICENSE).

`install/setup-hyprbuntu.sh` is from [kralos/hyprbuntu](https://gitlab.com/kralos/hyprbuntu/-/blob/main/LICENCE?ref_type=heads) which is also MIT licensed. Its copyright notice is kept at [`install/LICENSE`](install/LICENSE)
