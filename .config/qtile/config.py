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
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

MOD = "mod4"
TERM = guess_terminal()


def send_to_next_screen(qtile):
    to_idx = (qtile.current_screen.index + 1) % len(qtile.screens)
    qtile.current_window.cmd_toscreen(to_idx)


def goto_next_empty_group(qtile):
    for group in qtile.groups:
        if not group.windows and not group.screen:
            qtile.current_screen.set_group(group)
            return


def followto_next_empty_group(qtile):
    "send and follow the selected window to a new group"
    for group in qtile.groups:
        if len(group.windows) == 0:
            qtile.current_window.cmd_togroup(group.name)
            qtile.current_screen.set_group(group)
            return


def swap_screens(qtile):
    qtile.screens[0].toggle_group(qtile.screens[1].group)


keys = [
    # Switch between windows
    Key([MOD], "b", lazy.spawn("firefox")),
    Key([MOD], "c", lazy.spawn("rofi -show window"), desc="pneumonic 'chase'"),
    Key([MOD], "f", lazy.next_layout()),
    Key([MOD], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([MOD], "j", lazy.layout.down(), desc="Move focus down"),
    Key([MOD], "k", lazy.layout.up(), desc="Move focus up"),
    Key([MOD], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([MOD], "m", lazy.layout.toggle_split()),
    Key([MOD], "n", lazy.spawn("foliate")),
    Key([MOD], "n", lazy.spawn("")),
    Key([MOD], "o", lazy.next_screen()),
    Key([MOD], "p", lazy.spawn("flameshot gui")),
    Key([MOD], "r", lazy.spawn("rofi -show run")),
    Key([MOD], "s", lazy.function(swap_screens)),
    Key([MOD], "t", lazy.function(goto_next_empty_group)),
    Key([MOD], "w", lazy.window.kill()),
    Key([MOD], "Return", lazy.spawn(TERM), desc="Launch terminal"),
    Key([MOD], "Space", lazy.screen.next_group(True, True)),
    Key([MOD], "Tab", lazy.screen.toggle_group()),

    Key([MOD, "Shift"], "h", lazy.layout.shuffle_left()),
    Key([MOD, "Shift"], "j", lazy.layout.shuffle_down()),
    Key([MOD, "Shift"], "k", lazy.layout.shuffle_up()),
    Key([MOD, "Shift"], "l", lazy.layout.shuffle_right()),
    Key([MOD, "Shift"], "n", lazy.spawn("xcwd-term")),
    Key([MOD, "Shift"], "o", lazy.function(send_to_next_screen)),
    Key([MOD, "Shift"], "t", lazy.function(followto_next_empty_group)),
    Key([MOD, "Shift"], "Space", lazy.screen.prev_group(True, True)),
    Key([MOD, "Shift"], "Return", lazy.window.toggle_floating()),

    Key([MOD, "Control"], "q", lazy.spawn("my-exit")),
    Key([MOD, "Control"], "r", lazy.restart()),
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
    Group("0")
]

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
    # layout.MonadTall(border_focus='fbf1c7',
    #                  border_normal='3c3836',
    #                  margin=20,
    #                  border_width=2,
    #                  single_margin=50),
    layout.Columns(border_focus='fbf1c7',
                   border_focus_stack='7b7157',
                   border_normal='3c3836',
                   border_normal_stack='2c2826',
                   margin=20,
                   border_width=2,
                   single_margin=50),
    layout.Max(),
]

widget_defaults = dict(
    font='Noto Sans',
    fontsize=14,
    padding=3,
    background="#282828",
    foreground="#ebdbb2",
)

extension_defaults = widget_defaults.copy()

common_bar_prefix = [
    widget.CurrentLayout(),
    widget.GroupBox(active="ebdbb2",
                    disable_drag=True,
                    highlight_method="block",
                    this_current_screen_border='928374',
                    this_screen_border='928374',
                    other_current_screen_border='3c3836',
                    other_screen_border='3c3836'),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Prompt(),
    widget.WindowName(),
    widget.OpenWeather(
        zip="35805",
        metric=False,
        format=
        '⛅ {main_temp} °{units_temperature} {humidity}% {weather_details}'),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Net(format="{down} ↓↑ {up}"),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.TextBox("CPU:"),
    widget.CPUGraph(samples=30),
]
common_bar_suffix = [
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Clock(format='%a %m/%d/%Y %H:%M:%S'),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Systray(),
]

bar_settings = {
    "opacity": 0.75
}

if os.uname()[1] == 'toaster':
    screens = [
        Screen(bottom=bar.Bar(common_bar_prefix +
                              common_bar_suffix, 24, **bar_settings)),
        # because of the way qtile works, we have to redefine our bar
        # rather than using the above array.
        Screen(bottom=bar.Bar([
            widget.CurrentLayout(),
            widget.GroupBox(active="ebdbb2",
                            disable_drag=True,
                            highlight_method="block",
                            this_current_screen_border='928374',
                            this_screen_border='928374',
                            other_current_screen_border='3c3836',
                            other_screen_border='3c3836'),
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
                widget.Battery(
                    format='⚡ {percent:2.0%} {hour:d}:{min:02d} {watt:.2f} W'),
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

# Drag floating layouts.
mouse = [
    Drag([MOD],
         "Button1",
         lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([MOD],
         "Button3",
         lazy.window.set_size(),
         start=lazy.window.get_size()),
    Click([MOD], "Button2", lazy.window.bring_to_front()),
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
focus_on_window_activation = "never"
reconfigure_screens = False

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
