#!/usr/bin/env bash
xset m 0/0 0 &
xset r rate 250 50 &
udiskie -s -2 &
xrandr --output DVI-D-0 --off
xinput set-prop 13 301 0, -1
