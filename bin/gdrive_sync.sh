#!/bin/bash

rclone copy crimsondrive:Calibre\ Library ~/Calibre\ Library;
while true; do\
          sleep 2s; \
          find ~/Calibre\ Library/ | entr -d rclone copy ~/Calibre\ Library/ crimsondrive:Calibre\ Library;\
          done
