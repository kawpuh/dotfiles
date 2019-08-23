#!/bin/bash
regex1="Logitech G203 Prodigy Gaming Mouse\\s*id=\\K[0-9]{2}"
out1=$(xinput | grep -oP "$regex1")
regex2="libinput Accel Profile Enabled \\(\\K[0-9]{3}"
out2=$(xinput list-props $out1 | grep -oP "$regex2")
echo "xinput set-prop $out1 $out2 0, -1"
xinput set-prop $out1 $out2 0, -1
