local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local walker = os.getenv("HOME") .. "/.local/share/omarchy-ubuntu/walker/shell/"
local waybar = os.getenv("HOME") .. "/.local/share/omarchy-ubuntu/waybar/shell/"
local shell = os.getenv("HOME") .. "/.local/share/omarchy-ubuntu/shell/"
local functions = require("functions")

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(Terminal), { description = "Open terminal" })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(Browser), { description = "Open browser" })
hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "Close active window" })

hl.bind(
	mainMod .. " + SHIFT + F",
	hl.dsp.exec_cmd(FileManager .. ' --new-window "$(' .. shell .. 'terminal-cwd.sh)"'),
	{ description = "Open file manager in terminal's cwd" }
)
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating window" })
-- "maximized" fills the monitor but respects reserved space (top bar stays visible)
hl.bind(
	mainMod .. " + ALT + F",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ description = "Toggle maximized window" }
)
hl.bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ description = "Toggle fullscreen window" }
)

-- border
hl.bind(mainMod .. " + SHIFT + BACKSPACE", functions.toggle_border, { description = "Toggle window border" })

-- waybar

hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(waybar .. "toggle.sh"))
--
--
-- menu
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(walker .. "appmenu.sh"), { description = "Open app launcher" })
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd(walker .. "/menu.sh"), { description = "Open menu" })
hl.bind(
	mainMod .. " + ALT +SHIFT + K",
	hl.dsp.exec_cmd(walker .. "/show-keybinds.sh"),
	{ description = "Show keybinds" }
)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudotiling" })
hl.bind(mainMod .. " + ALT + J", hl.dsp.layout("togglesplit"), { description = "Toggle split direction" }) -- dwindle onl
-- Move focus with mainMod + arrow keys
-- hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
-- hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
-- hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
-- hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })
-- Swap the active window itself with mainMod + SHIFT + arrow keys
-- hl.bind(
-- 	mainMod .. " + SHIFT + left",
-- 	hl.dsp.window.swap({ direction = "left" }),
-- 	{ description = "Swap window to left" }
-- )
-- hl.bind(
-- 	mainMod .. " + SHIFT + right",
-- 	hl.dsp.window.swap({ direction = "right" }),
-- 	{ description = "Swap window to right" }
-- )
-- hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
-- hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }), { description = "Swap window to left" })
hl.bind(
	mainMod .. " + SHIFT + l",
	hl.dsp.window.swap({ direction = "right" }),
	{ description = "Swap window to right" }
)
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i, follow = false }),
		{ description = "Move window to workspace " .. i }
	)
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad workspace" })
hl.bind(
	mainMod .. " + ALT + SHIFT + S",
	hl.dsp.window.move({ workspace = "special:magic", follow = false }),
	{ description = "Move window to scratchpad" }
)

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Switch to next workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Switch to previous workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Laptop multimedia keys for volume and LCD brightness
-- Currently don't use
-- hl.bind(
-- 	"XF86AudioRaiseVolume",
-- 	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
-- 	{ locked = true, repeating = true, description = "Raise volume" }
-- )
-- hl.bind(
-- 	"XF86AudioLowerVolume",
-- 	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
-- 	{ locked = true, repeating = true, description = "Lower volume" }
-- )
-- hl.bind(
-- 	"XF86AudioMute",
-- 	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
-- 	{ locked = true, repeating = true, description = "Toggle mute" }
-- )
-- hl.bind(
-- 	"XF86AudioMicMute",
-- 	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
-- 	{ locked = true, repeating = true, description = "Toggle microphone mute" }
-- )
-- hl.bind(
-- 	"XF86MonBrightnessUp",
-- 	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
-- 	{ locked = true, repeating = true, description = "Raise screen brightness" }
-- )
-- hl.bind(
-- 	"XF86MonBrightnessDown",
-- 	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
-- 	{ locked = true, repeating = true, description = "Lower screen brightness" }
-- )

local osd = [[swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"]]
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(osd .. " --output-volume raise --max-volume 100"),
	{ locked = true, repeating = true, description = "Raise volume" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(osd .. " --output-volume lower"),
	{ locked = true, repeating = true, description = "Lower volume" }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(osd .. " --output-volume mute-toggle"),
	{ locked = true, description = "Toggle mute" }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(osd .. " --input-volume mute-toggle"),
	{ locked = true, description = "Toggle microphone mute" }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(osd .. " --brightness raise"),
	{ locked = true, repeating = true, description = "Raise screen brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(osd .. " --brightness lower"),
	{ locked = true, repeating = true, description = "Lower screen brightness" }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next media track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause media" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause media" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous media track" })

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd(shell .. "snip.sh -m region"), { description = "Region screenshot" })
hl.bind("ALT + PRINT", hl.dsp.exec_cmd(shell .. "snip.sh -m window"), { description = "Window screenshot" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(shell .. "snip.sh -m output"), { description = "Monitor screenshot" })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(shell .. "snip.sh -m region"), { description = "Region screenshot" })
-- notification mako
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("makoctl dismiss"), { description = "Dismiss last notification" })
hl.bind("SUPER + SHIFT + COMMA", hl.dsp.exec_cmd("makoctl dismiss -a"), { description = "Dismiss all notifications" })
hl.bind("SUPER + CTRL + COMMA", hl.dsp.exec_cmd("makoctl restore"), { description = "Open notifications panel" })
hl.bind(
	"SUPER + ALT + COMMA",
	hl.dsp.exec_cmd(
		"makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send 'Silenced notifications' || notify-send 'Enabled notifications'"
	),
	{ description = "Toggle silencing notifications" }
)
