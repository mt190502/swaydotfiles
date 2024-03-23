#!/bin/bash
#################################################
##
#### Dropdown terminal
##
#################################################
#~~~ set term width and height
TERM='Alacritty'

scrwidth=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .rect.width')

if [[ -z "$(ps aux | grep -v grep | grep -o dropterminal)" ]]; then
	swaymsg for_window "[app_id=\"$TERM\" title=\"dropterminal\"] move container to scratchpad"
	sleep 0.15
	${TERM,,} -t dropterminal -e tmux attach-session -t dropterminaltmux &
	sleep 0.15
fi
swaymsg "[app_id=\"$TERM\" title=\"dropterminal\"] scratchpad show, resize set 50ppt 50ppt, floating enable, move position $(( $(( $scrwidth * 25)) / 100 )) 0"

