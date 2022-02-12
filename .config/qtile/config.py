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


def toggle_maximized_tiled(qtile):
    idx = qtile.current_group.current_layout
    if idx == 1:
        qtile.cmd_to_layout_index(0)
    else:
        qtile.cmd_to_layout_index(1)


def toggle_tabbed_tiled(qtile):
    idx = qtile.current_group.current_layout
    if idx == 2:
        qtile.cmd_to_layout_index(0)
    else:
        qtile.cmd_to_layout_index(2)


keys = [
    # Switch between windows
    Key([MOD], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([MOD], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([MOD], "j", lazy.layout.down(), desc="Move focus down"),
    Key([MOD], "k", lazy.layout.up(), desc="Move focus up"),

    Key([MOD], "a", lazy.spawn("agenda")),
    Key([MOD], "n", lazy.spawn("notes")),

    Key([MOD], "p", lazy.spawn("flameshot gui")),

    Key([MOD], "Tab", lazy.screen.toggle_group()),

    Key([MOD, "shift"], "h", lazy.layout.shuffle_left()),
    Key([MOD, "shift"], "l", lazy.layout.shuffle_right()),
    Key([MOD, "shift"], "j", lazy.layout.shuffle_down()),
    Key([MOD, "shift"], "k", lazy.layout.shuffle_up()),

    Key([MOD, "control"], "j", lazy.layout.shrink()),
    Key([MOD, "control"], "k", lazy.layout.grow()),
    Key([MOD, "control"], "s", lazy.layout.reset()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([MOD, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),

    Key([MOD], "Return", lazy.spawn(TERM), desc="Launch terminal"),
    Key([MOD, "shift"], "n", lazy.spawn("xcwd-term")),

    Key([MOD], "f", lazy.function(toggle_maximized_tiled)),
    Key([MOD], "g", lazy.function(toggle_tabbed_tiled)),
    Key([MOD], "s", lazy.function(lambda qtile: qtile.cmd_to_layout_index(0))),

    # Swap between monitors
    Key([MOD], "o", lazy.next_screen()),

    # Some spawn commands
    Key([MOD], "b", lazy.spawn("firefox")),

    Key([MOD], "w", lazy.window.kill()),

    Key([MOD, "control"], "r", lazy.restart()),
    Key([MOD, "control"], "q", lazy.spawn("my-exit")),
    Key([MOD], "r", lazy.spawn("rofi -show combi")),
]

# setup hostname specific keys
if os.uname()[1] == 'trailer':
    keys.extend([
        Key([], "XF86MonBrightnessUp", lazy.spawn(
            "brightnessctl s +10%"), desc="Brightness up"),
        Key([], "XF86MonBrightnessDown", lazy.spawn(
            "brightnessctl s 10%-"), desc="Brightness down"),
    ])
elif os.uname()[1] == 'camper':
    keys.extend([
        Key([MOD], "d", lazy.spawn("camper-displays-gui"),
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
    Group("9", layout="treetab"),
    Group("0", layout="treetab")
]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([MOD], i.name, lazy.group[i.name].toscreen(toggle=False),
            desc="Switch to group {}".format(i.name)),
        # mod1 + shift + letter of group = move focused window to group
        Key([MOD, "shift"], i.name, lazy.window.togroup(i.name),
            desc="move focused window to group  {}".format(i.name)),
    ])

layouts = [
    layout.MonadTall(border_focus='928374', border_normal='3c3836', margin=25,
                     border_width=2, single_margin=50),
    layout.Max(),
    layout.TreeTab(
        active_bg='665c54',
        inactive_bg='3c3836',
        bg_color='1d2021',
        font='Iosevka SS09',
        fontsize=14,
        padding_x=3,
        level_shift=0)
]

widget_defaults = dict(
    font='Iosevka SS09',
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
    widget.Prompt(),
    widget.WindowName(background="3c3836"),
    widget.OpenWeather(
        zip="35114",
        metric=False,
        format='⛅: {main_temp} °{units_temperature} {humidity}% {weather_details}'),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Net(),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.TextBox("CPU:"),
    widget.CPUGraph(),
]
common_bar_suffix = [
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Clock(format='%a %m/%d/%Y %H:%M:%S'),
    widget.Sep(padding=12, size_percent=80, foreground="504945"),
    widget.Systray(),
]

if os.uname()[1] == 'toaster':
    screens = [
        Screen(bottom=bar.Bar(common_bar_prefix + common_bar_suffix, 24)),
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
            widget.WindowName(background="3c3836"),
            widget.Clock(format='%a %m/%d/%Y %H:%M:%S')], 24))
    ]
elif os.uname()[1] == 'trailer':
    screens = [
        Screen(
            bottom=bar.Bar(
                common_bar_prefix +
                [
                    widget.Sep(padding=12, size_percent=80,
                               foreground="504945"),
                    widget.Battery(
                        format='⚡ {percent:2.0%} {hour:d}:{min:02d} {watt:.2f} W'),
                    widget.Sep(padding=12, size_percent=80,
                               foreground="504945"),
                    widget.TextBox("💡:"),
                    widget.Backlight(
                        brightness_file="/sys/class/backlight/intel_backlight/brightness",
                        max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness"
                    ), ] + common_bar_suffix,
                24,
            ),
        ),
    ]
elif os.uname()[1] == 'camper':
    screens = [
        Screen(
            bottom=bar.Bar(
                common_bar_prefix +
                [
                    widget.Sep(padding=12, size_percent=80,
                               foreground="504945"),
                    widget.Battery(
                        format='⚡ {percent:2.0%} {hour:d}:{min:02d} {watt:.2f} W'),
                    widget.Sep(padding=12, size_percent=80,
                               foreground="504945"),
                    widget.Backlight(),
                ] + common_bar_suffix,
                24,
            ),
        ),
    ]

# Drag floating layouts.
mouse = [
    Drag([MOD], "Button3", lazy.window.set_size(),
         start=lazy.window.get_size()),
    Click([MOD], "Button2", lazy.window.bring_to_front()),
    Click([], "Button8", lazy.next_screen())
]

focus_on_window_activation = "never"

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
# focus_on_window_activation = "smart"
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
