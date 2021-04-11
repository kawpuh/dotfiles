#!/usr/bin/env bash
xrdb ~/.Xresources
xset r rate 250 50
xset -b
no-accel
~/.fehbg
udiskie -s -2  &
nm-applet &
redshift-gtk -t 6500K:2000K &
