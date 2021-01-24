#!/usr/bin/env bash
# xset m 0/0 0 
xset -b
xset r rate 250 50
udiskie -s -2  &
feh --bg-scale ~/Pictures/Pablo\ Garcia\ Saldana.jpg
nm-applet &
redshift-gtk -t 6500K:4000K &
