#!/usr/bin/env bash
xset r rate 250 50
xset -b
no-accel
~/.fehbg
xrandr --output DVI-D-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-0 --mode 1920x1080 --pos 0x0 --rotate normal --rate 144
udiskie -s -2  &
redshift-gtk -t 6500K:4000K &
nm-applet &
