#!/bin/bash
# Toggle visualizer:
# Deps : xdotool kitty termincal cava
# Kill it if you get nothing, there is an invisible terminal window running now
# Created by the LEGENDARY Elenapan from /r/unixporn -- slight changes to make a more universal copy, brought to you by nylar357
xdotool search --class Visualizer &>/dev/null && (ps x | grep "kitty --class Visualizer" | grep -v grep | awk '{print $1}' | xargs kill) || kitty --class Visualizer -o background_opacity=0 -o font_size=6 -o window_margin_width=0 -e cava &
