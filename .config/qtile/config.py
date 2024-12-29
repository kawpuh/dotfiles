# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
from typing import List  # noqa: F401
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from libqtile.log_utils import logger

MOD = "mod4"
TERM = "ghostty"

# TODO: mark/unmark groups not to be visited by mod+space and mod+t

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

def toggle_w_columns(qtile, alt_layout):
  if qtile.current_screen.group.layout.name == alt_layout:
    qtile.current_screen.group.cmd_setlayout('columns')
  else:
    qtile.current_screen.group.cmd_setlayout(alt_layout)

keys = [
  # Switch between windows
  Key([MOD], "a", lazy.spawn("kitty -o font_size=20 notes"), desc="mnemonic 'agenda'"),
  Key([MOD], "b", lazy.spawn("firefox")),
  Key([MOD], "f", lazy.function(toggle_w_columns, "max")),
  Key([MOD], "h", lazy.layout.left(), desc="Move focus to left"),
  Key([MOD], "j", lazy.group.next_window(), desc="Move focus down"),
  Key([MOD], "k", lazy.group.prev_window(), desc="Move focus up"),
  Key([MOD], "l", lazy.layout.right(), desc="Move focus to right"),
  Key([MOD],
      "m",
      lazy.function(goto_next_hidden_group),
      desc="Mnemonic masked"),
  Key([MOD], "n", lazy.spawn("foliate")),
  Key([MOD], "o", lazy.next_screen()),
  Key([MOD], "p", lazy.spawn("flameshot gui")),
  Key([MOD], "r", lazy.spawn("rofi -show run")),
  Key([MOD,"shift"], "r", lazy.spawn("rofi -show combi")),
  Key([MOD], "s", lazy.function(swap_screens)),
  Key([MOD], "t", lazy.function(goto_next_empty_group)),
  Key([MOD], "u", lazy.window.bring_to_front()),
  Key([MOD], "w", lazy.window.kill()),
  Key([MOD], "z", lazy.layout.toggle_split(), desc="Mnemonic zip"),
  Key([MOD], "bracketleft", lazy.spawn("kitty -o font_size=48 vi")),
  Key([MOD], "comma", lazy.spawn("zathura")),
  Key([MOD], "Return", lazy.spawn(TERM), desc="Launch terminal"),
  Key([MOD], "Space", lazy.function(goto_next_unhidden_group)),
  Key([MOD], "Tab", lazy.screen.toggle_group()),
  Key([MOD, "Shift"], "c", lazy.spawn("kitty nvim .config/qtile/config.py")),
  Key([MOD, "Shift"], "f", lazy.function(toggle_bar_and_fullscreen)),
  Key([MOD, "Shift"], "h", lazy.layout.shuffle_left()),
  Key([MOD, "Shift"], "j", lazy.layout.shuffle_down()),
  Key([MOD, "Shift"], "k", lazy.layout.shuffle_up()),
  Key([MOD, "Shift"], "l", lazy.layout.shuffle_right()),
  Key([MOD, "Shift"],
      "m",
      lazy.function(sendto_next_hidden_group),
      desc="Mnemonic masked"),
  Key([MOD, "Shift"], "n", lazy.spawn("xcwd-term")),
  Key([MOD, "Shift"], "o", lazy.function(send_to_next_screen)),
  Key([MOD, "Shift"], "t", lazy.function(followto_next_empty_group)),
  Key([MOD, "Shift"], "Space", lazy.function(goto_prev_unhidden_group)),
  Key([MOD, "Shift"], "Return", lazy.window.toggle_floating()),
  Key([MOD, "Control"], "q", lazy.spawn("my-exit")),
  Key([MOD, "Control"], "r", lazy.restart()),
  # wake from suspend is broken on toaster right now
  Key([MOD, "Control"], "s", lazy.spawn("xset dpms force off")) \
  if os.uname()[1] == 'toaster' else \
  Key([MOD, "Control"], "s", lazy.spawn("systemctl suspend"))
  ,
  Key([MOD], "Up", lazy.spawn("xdotool mousemove_relative -- 0 -15")),
  Key([MOD], "Down", lazy.spawn("xdotool mousemove_relative 0 15")),
  Key([MOD], "Left", lazy.spawn("xdotool mousemove_relative -- -15 0")),
  Key([MOD], "Right", lazy.spawn("xdotool mousemove_relative 15 0")),
  Key([MOD, "Shift"], "Up", lazy.spawn("xdotool mousemove_relative -- 0 -200")),
  Key([MOD, "Shift"], "Down", lazy.spawn("xdotool mousemove_relative 0 200")),
  Key([MOD, "Shift"], "Left", lazy.spawn("xdotool mousemove_relative -- -300 0")),
  Key([MOD, "Shift"], "Right", lazy.spawn("xdotool mousemove_relative 300 0")),
  KeyChord([MOD], "Next", [
    Key([], "Left", lazy.spawn("xdotool click 1")),
    Key([], "Right", lazy.spawn("xdotool click 3")),
  ]),
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
if os.uname()[1] == 'trailer':
  keys.extend([
    Key([],
        "XF86MonBrightnessUp",
        lazy.spawn("xbacklight -inc 10"),
        desc="Coarse Brightness up"),
    Key([],
        "XF86MonBrightnessDown",
        lazy.spawn("xbacklight -dec 10"),
        desc="Coarse Brightness down"),
    Key(["shift"],
        "XF86MonBrightnessUp",
        lazy.spawn("xbacklight -inc 5"),
        desc="Fine Brightness up"),
    Key(["shift"],
        "XF86MonBrightnessDown",
        lazy.spawn("xbacklight -dec 5"),
        desc="Fine Brightness down"),
  ])
elif os.uname()[1] == 'camper':
  keys.extend([
    Key([MOD],
        "d",
        lazy.spawn("camper-displays-gui"),
        desc="GUI for setting up xrandr displays"),
  ])
elif os.uname()[1] == 'campstove':
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

layouts = [
  layout.Columns(
    border_focus='#d5c4a1',
    border_focus_stack='#d76921',
    border_normal='#3c3836',
    border_normal_stack='#2c2826',
    margin=4,
    margin_on_single=[8,240,8,240],
    border_width=2 if os.uname()[1] != "campstove" else 4,
    border_on_single=True,
  ),
  layout.Max(),
]

widget_defaults = dict(
  font='Noto Sans',
  fontsize=12 if os.uname()[1] != "campstove" else 28,
  padding=4,
  background="#282828",
  foreground="#ebdbb2",
)

extension_defaults = widget_defaults.copy()

common_bar_prefix = [
  widget.CurrentLayoutIcon(),
  widget.GroupBox(active="ebdbb2",
                  disable_drag=True,
                  highlight_method="line",
                  this_current_screen_border='928374',
                  this_screen_border='928374',
                  other_current_screen_border='504945',
                  other_screen_border='504945'),
  widget.Sep(padding=12, size_percent=80, foreground="504945"),
  widget.Prompt(),
  widget.WindowName(),
  widget.OpenWeather(
    zip="35114",
    update_interval=120,
    metric=False,
    format='{icon} {main_temp} °{units_temperature} 💧{humidity}%'),
  widget.Sep(padding=12, size_percent=80, foreground="504945"),
  widget.Net(format="{down:.0f} {down_suffix} ↓↑ {up:.0f} {up_suffix}"),
  widget.Sep(padding=12, size_percent=80, foreground="504945"),
  widget.TextBox("CPU:"),
  widget.CPUGraph(samples=30),
  widget.TextBox("Disk:"),
  widget.HDDBusyGraph(samples=30),
  widget.Memory(measure_mem="G"),
  widget.Sep(linewidth=2, padding=12, size_percent=80, foreground="504945"),
  widget.TextBox("🔊:"),
  widget.PulseVolume(mute_format="🔇"),
]
common_bar_suffix = [
  widget.Sep(padding=12, size_percent=80, foreground="504945"),
  widget.Clock(format='%a %m/%d/%Y %H:%M:%S'),
  widget.Sep(padding=12, size_percent=80, foreground="504945"),
  widget.Systray(icon_size=20 if os.uname()[1] != "campstove" else 40),
]

bar_settings = {"opacity": 0.75}

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
      widget.Sep(padding=12, size_percent=80, foreground="504945"),
      widget.WindowName(),
      widget.Clock(format='%a %m/%d/%Y %H:%M:%S')
    ], 24, **bar_settings))
  ]
elif os.uname()[1] == 'trailer':
  screens = [
    Screen(bottom=bar.Bar(
      common_bar_prefix + [
        widget.Sep(padding=12, size_percent=80, foreground="504945"),
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
        widget.Sep(padding=12, size_percent=80, foreground="504945"),
        widget.Battery(
          format='⚡ {percent:2.0%} {hour:d}:{min:02d} {watt:.2f} W'),
        widget.Sep(padding=12, size_percent=80, foreground="504945"),
        widget.Backlight(),
      ] + common_bar_suffix, 24, **bar_settings), ),
  ]
elif os.uname()[1] == 'campstove':
  screens = [
    Screen(bottom=bar.Bar(
      common_bar_prefix + [
        widget.Sep(linewidth=2, padding=12, size_percent=80, foreground="504945"),
        widget.TextBox("💡:"),
        widget.Backlight(
          brightness_file=
          "/sys/class/backlight/amdgpu_bl1/brightness",
          max_brightness_file=
          "/sys/class/backlight/amdgpu_bl1/max_brightness"),
        widget.Sep(linewidth=2, padding=12, size_percent=80, foreground="504945"),
        widget.Battery(not_charging_char="🔋", charge_char="⚡", discharge_char="🪫", empty_char="💀",
                       charge_controller=lambda: (0, 90), update_interval=15),
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
