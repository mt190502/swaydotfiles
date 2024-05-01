#!/bin/bash
[[ -z $1 ]] && { notify-send "No mode specified..."; exit; }
[[ -z $2 ]] && { notify-send "No workspace specified..."; exit; }
active_monitor=$(swaymsg -t get_outputs | jq -r '.[] | select (.focused) | .name')
case $1 in
	init)
		for monitor in $(swaymsg -t get_workspaces | jq -r ".[].output"); do
			swaymsg workspace 1-$monitor output $monitor
			swaymsg workspace 1-$monitor
		done
	;;
	switch)
		swaymsg workspace $2-$active_monitor output $active_monitor
		swaymsg workspace $2-$active_monitor
	;;
	move-container)
		swaymsg move container to workspace $2-$active_monitor
	;;
esac
