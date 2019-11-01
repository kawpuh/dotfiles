#!/usr/bin/env bash
# xset m 0/0 0 
xset r rate 250 50
udiskie -s -2  &
xrandr --output DVI-D-0 --auto
xrandr --output HDMI-0 --auto --left-of DVI-D-0
gdrive_sync.sh &
shared_sync.sh &
redshift-gtk -t 6500K:4000K &
no-accel.sh &
