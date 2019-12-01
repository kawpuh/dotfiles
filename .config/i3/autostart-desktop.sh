#!/usr/bin/env bash
xset r rate 250 50
xset -b
udiskie -s -2  &
xrandr --output DVI-D-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal
feh --bg-fill /home/ethan/.config/10-14-Night.jpg
redshift-gtk -t 6500K:4000K &
nm-applet &
gdrive_sync.sh &
no-accel.sh &
