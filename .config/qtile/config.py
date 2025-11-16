import os
from typing import List  # noqa: F401
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from libqtile.log_utils import logger

colors = {
  "base"     : "1e1e2e",
  "mantle"   : "181825",
  "surface0" : "313244",
  "surface1" : "45475a",
  "surface2" : "585b70",
  "text"     : "cdd6f4",
  "rosewater": "f5e0dc",
  "lavender" : "b4befe",
  "red"      : "f38ba8",
  "peach"    : "fab387",
  "yellow"   : "f9e2af",
  "green"    : "a6e3a1",
  "teal"     : "94e2d5",
  "blue"     : "89b4fa",
  "mauve"    : "cba6f7",
  "flamingo" : "f2cdcd",
}

MOD = "mod4"

def send_to_next_screen(qtile):
  to_idx = (qtile.current_screen.index + 1) % len(qtile.screens)
  qtile.current_window.cmd_toscreen(to_idx)

def group_shown(group):
  return group.windows or group.screen

def goto_next_empty_group(qtile):
  for group in qtile.groups:
    if not group_shown(group):
      qtile.current_screen.set_group(group)
      return

def followto_next_empty_group(qtile):
  "send and follow the selected window to a new group"
  for group in qtile.groups:
    if not group_shown(group):
      qtile.current_window.cmd_togroup(group.name)
      qtile.current_screen.set_group(group)
      return

def goto_next_unhidden_group(qtile):
  group = qtile.current_screen.group
  for i in range(10):
    group = group.get_next_group(skip_empty=True, skip_managed=True)
    if group.name not in hidden_group_names:
      qtile.current_screen.set_group(group)
      return

def goto_prev_unhidden_group(qtile):
  group = qtile.current_screen.group
  for i in range(10):
    group = group.get_previous_group(skip_empty=True, skip_managed=True)
    if group.name not in hidden_group_names:
      qtile.current_screen.set_group(group)
      return

def goto_next_hidden_group(qtile):
  group = qtile.current_screen.group
  for i in range(10):
    group = group.get_next_group(skip_empty=False, skip_managed=True)
    if group.name in hidden_group_names:
      qtile.current_screen.set_group(group)
      return

def sendto_next_hidden_group(qtile):
  group = qtile.current_screen.group
  for i in range(10):
    group = group.get_next_group(skip_empty=False, skip_managed=False)
    if group.name in hidden_group_names:
      qtile.current_window.cmd_togroup(group.name)
      return

def swap_screens(qtile):
  qtile.screens[0].toggle_group(qtile.get_screens()[1]['group'])
  shown = qtile.screens[0].bottom.is_show(), qtile.screens[1].bottom.is_show()
  qtile.screens[0].bottom.show(shown[1])
  qtile.screens[1].bottom.show(shown[0])

def toggle_bar_and_fullscreen(qtile):
  bar = qtile.current_screen.bottom
  if bar.is_show():
    bar.show(False)
    qtile.current_screen.group.cmd_setlayout('max')
  else:
    bar.show(True)

def shuffle_to_second(qtile):
  windows = qtile.current_group.windows
  start_idx = qtile.current_layout.info()['current']
  if start_idx > 1:
    for _ in range(start_idx - 1):
      qtile.current_layout.shuffle_up()


layouts = [
  layout.MonadTall(
    auto_maximize=True,
    min_secondary_size=200,
    border_focus=colors["red"],
    border_normal=colors["surface2"],
    margin=4,
    border_width=4 if os.uname()[1] != "campstove" else 6,
    border_on_single=True,
  ),
  layout.Max(),
]

keys = [
  # Switch between windows
  Key([MOD], "a", lazy.spawn("ghostty --font-size=20 -e nvim /home/ethan/Sync/notes/agenda.md")),
  Key([MOD], "b", lazy.spawn("qutebrowser")),
  Key([MOD, "shift"], "b", lazy.spawn("chromium")),
  Key([MOD], "c", lazy.spawn("bt-script")),
  Key([MOD, "Shift"], "c", lazy.spawn("ghostty -e nvim /home/ethan/.config/qtile/config.py")),
  Key([MOD], "d", lazy.window.move_down(force=True)),
  Key([MOD], "e", lazy.spawn("ghostty -e nvim -c ':Scratch'")),
  Key([MOD], "f", lazy.next_layout()),
  Key([MOD], "h", lazy.layout.left()),
  Key([MOD], "j", lazy.group.next_window()),
  Key([MOD], "k", lazy.group.prev_window()),
  Key([MOD], "l", lazy.layout.right()),
  Key([MOD], "m", lazy.function(goto_next_hidden_group)),
  Key([MOD], "n", lazy.spawn("sitelist")),
  Key([MOD], "o", lazy.next_screen()),
  Key([MOD], "p", lazy.spawn("flameshot gui")),
  Key([MOD], "r", lazy.spawn("rofi -show run")),
  Key([MOD,"shift"], "r", lazy.spawn("rofi -show combi")),
  Key([MOD], "s", lazy.function(swap_screens)),
  Key([MOD], "t", lazy.function(goto_next_empty_group)),
  Key([MOD], "u", lazy.window.bring_to_front()),
  Key([MOD], "w", lazy.window.kill()),
  Key([MOD], "comma", lazy.spawn("zathura")),
  Key([MOD], "Return", lazy.spawn("ghostty --window-inherit-working-directory=false")),
  Key([MOD], "Space", lazy.function(goto_next_unhidden_group)),
  Key([MOD], "Tab", lazy.screen.toggle_group()),
  Key([MOD, "Shift"], "f", lazy.function(toggle_bar_and_fullscreen)),
  Key([MOD, "Shift"], "i", lazy.function(shuffle_to_second)),
  Key([MOD, "Shift"], "h", lazy.layout.shuffle_left()),
  Key([MOD, "Shift"], "j", lazy.layout.shuffle_down()),
  Key([MOD, "Shift"], "k", lazy.layout.shuffle_up()),
  Key([MOD, "Shift"], "l", lazy.layout.shuffle_right()),
  Key([MOD, "Shift"], "m", lazy.function(sendto_next_hidden_group)),
  Key([MOD, "Shift"], "n", lazy.spawn("xcwd-term")),
  Key([MOD, "Shift"], "o", lazy.function(send_to_next_screen)),
  Key([MOD, "Shift"], "t", lazy.function(followto_next_empty_group)),
  Key([MOD, "Shift"], "Space", lazy.function(goto_prev_unhidden_group)),
  Key([MOD, "Shift"], "Return", lazy.window.toggle_floating()),
  Key([MOD, "Control"], "b", lazy.spawn("bt-script")),
  Key([MOD, "Control"], "q", lazy.spawn("exit-script")),
  Key([MOD, "Control"], "r", lazy.restart()),
  Key([MOD], "Up", lazy.spawn("xdotool mousemove_relative -- 0 -15")),
  Key([MOD], "Down", lazy.spawn("xdotool mousemove_relative 0 15")),
  Key([MOD], "Left", lazy.spawn("xdotool mousemove_relative -- -15 0")),
  Key([MOD], "Right", lazy.spawn("xdotool mousemove_relative 15 0")),
  Key([MOD, "Shift"], "Up", lazy.spawn("xdotool mousemove_relative -- 0 -200")),
  Key([MOD, "Shift"], "Down", lazy.spawn("xdotool mousemove_relative 0 200")),
  Key([MOD, "Shift"], "Left", lazy.spawn("xdotool mousemove_relative -- -300 0")),
  Key([MOD, "Shift"], "Right", lazy.spawn("xdotool mousemove_relative 300 0")),
  Key([MOD, "mod1"], "Left", lazy.spawn("xdotool click 1")),
  Key([MOD, "mod1"], "Right", lazy.spawn("xdotool click 3")),
  # media keys
  Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
  Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
  Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
  Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
  Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")),
  Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")),
]

mouse = [
  Drag([MOD],
       "Button1",
       lazy.window.set_position_floating(),
       start=lazy.window.get_position()),
  Drag([MOD],
       "Button3",
       lazy.window.set_size_floating(),
       start=lazy.window.get_size()),
  Click([MOD], "Button2", lazy.window.bring_to_front()),
  Click([MOD], "Button8", lazy.next_screen()),
  Click([MOD, "Shift"], "Button8", lazy.function(send_to_next_screen)),
]

# setup hostname specific keys
if os.uname()[1] in ['campstove', 'trailer']:
  keys.extend([
    Key([],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl s +10%"),
        desc="Coarse Brightness up"),
    Key([],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl s 10%-"),
        desc="Coarse Brightness down"),
    Key(["shift"],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl s +5%"),
        desc="Fine Brightness up"),
    Key(["shift"],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl s 5%-"),
        desc="Fine Brightness down"),
  ])

groups = [
  Group("1"),
  Group("2"),
  Group("3"),
  Group("4"),
  Group("5"),
  Group("6"),
  Group("7"),
  Group("8"),
  Group("9"),
  Group("0"),
]
hidden_group_names = ["8", "9", "0"]

for i in groups:
  keys.extend([
    # mod1 + letter of group = switch to group
    Key([MOD],
        i.name,
        lazy.group[i.name].toscreen(toggle=False),
        desc="Switch to group {}".format(i.name)),
    # mod1 + shift + letter of group = move focused window to group
    Key([MOD, "shift"],
        i.name,
        lazy.window.togroup(i.name),
        desc="move focused window to group  {}".format(i.name)),
  ])

widget_defaults = dict(
  font='Monaspace Argon',
  fontsize=12 if os.uname()[1] != "campstove" else 28,
  background=colors["base"],
  foreground=colors["text"],
)
extension_defaults = widget_defaults.copy()

sep = widget.Sep(padding=12, size_percent=80, foreground=colors["surface2"])

common_bar_prefix = [
  widget.CurrentLayout(mode="icon"),
  widget.GroupBox(active=colors["text"],
                  disable_drag=True,
                  highlight_method="line",
                  this_current_screen_border=colors["teal"],
                  this_screen_border=colors["surface2"],
                  other_current_screen_border=colors["surface0"],
                  other_screen_border=colors["surface0"]),
  sep,
  widget.WindowName(max_chars=15),
  widget.OpenWeather(
    zip="35114",
    update_interval=120,
    metric=False,
    format='{icon} {main_temp} °{units_temperature} 💧{humidity}%'),
  sep,
  widget.Net(format="{up:3.0f} {up_suffix:>2} ↑↓ {down:3.0f} {down_suffix:>2}"),
  sep,
  widget.TextBox("CPU"),
  widget.CPUGraph(samples=30, graph_color=colors["blue"], type="line"),
  widget.TextBox("Disk"),
  widget.HDDBusyGraph(samples=30, graph_color=colors["blue"], type="line"),
  widget.Memory(measure_mem="G"),
  sep,
  widget.TextBox("🔊"),
  widget.PulseVolume(mute_format="🔇"),
]
common_bar_suffix = [
  sep,
  widget.Clock(format='%a %m/%d/%Y %H:%M:%S'),
  sep,
  widget.Systray(icon_size=20 if os.uname()[1] != "campstove" else 40),
]

bar_settings = {"opacity": 0.80}

if os.uname()[1] == 'toaster':
  screens = [
    Screen(bottom=bar.Bar(common_bar_prefix +
      common_bar_suffix, 24, **bar_settings)),
    # it seems we can't easily deepcopy bar; have to redefine
    Screen(bottom=bar.Bar([
      widget.CurrentLayoutIcon(),
      widget.GroupBox(active="ebdbb2",
                      disable_drag=True,
                      highlight_method="line",
                      this_current_screen_border='928374',
                      this_screen_border='928374',
                      other_current_screen_border='504945',
                      other_screen_border='504945'),
      sep,
      widget.WindowName(),
      widget.Clock(format='%a %m/%d/%Y %H:%M:%S')
    ], 24, **bar_settings))
  ]
elif os.uname()[1] == 'trailer':
  screens = [
    Screen(bottom=bar.Bar(
      common_bar_prefix + [
        sep,
        widget.TextBox("💡:"),
        widget.Backlight(
          brightness_file=
          "/sys/class/backlight/intel_backlight/brightness",
          max_brightness_file=
          "/sys/class/backlight/intel_backlight/max_brightness"),
      ] + common_bar_suffix, 24, **bar_settings), ),
  ]
elif os.uname()[1] == 'camper':
  screens = [
    Screen(bottom=bar.Bar(
      common_bar_prefix + [
        sep,
        widget.Battery(not_charging_char="🔋", charge_char="⚡", discharge_char="🪫", empty_char="💀", update_interval=15),
        sep,
        widget.Backlight(),
      ] + common_bar_suffix, 24, **bar_settings), ),
  ]
elif os.uname()[1] == 'campstove':
  screens = [
    Screen(bottom=bar.Bar(
      common_bar_prefix + [
        sep,
        widget.TextBox("💡"),
        widget.Backlight(
          brightness_file= "/sys/class/backlight/amdgpu_bl1/brightness",
          max_brightness_file= "/sys/class/backlight/amdgpu_bl1/max_brightness",
          padding=3),
        sep,
        widget.Battery(not_charging_char="🔋", charge_char="⚡", discharge_char="🪫",
                       empty_char="💀", update_interval=15, notify_below=0.15,
                       format="{char} {percent:2.0%} {hour:d}:{min:02d} {watt:.0f} W"),
      ] + common_bar_suffix, 48, **bar_settings), ),
  ]

focus_on_window_activation = "never"

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
floating_layout = layout.Floating(float_rules=[
  # Run the utility of `xprop` to see the wm class and name of an X client.
  *layout.Floating.default_float_rules,
  Match(wm_class='confirmreset'),  # gitk
  Match(wm_class='makebranch'),  # gitk
  Match(wm_class='maketag'),  # gitk
  Match(wm_class='ssh-askpass'),  # ssh-askpass
  Match(wm_class='steam_app_1172470'),
  Match(wm_class='Wine'),  # apex
  Match(wm_type='splash'),
  Match(title='branchdialog'),  # gitk
  Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
auto_minimize = True
focus_on_window_activation = "never"
reconfigure_screens = False

# IDK java UI toolkits mess up without it (e.g. android-studio)
wmname = "LG3D"
