#!/usr/bin/env bash

MODE=${1:-drun}

if pgrep -x "rofi" > /dev/null; then
    pkill rofi
else
    rofi -show "$MODE" -config ~/.config/rofi/config.rasi  -font "GohuFont 14 Nerd Font 16" -normal-window
fi
