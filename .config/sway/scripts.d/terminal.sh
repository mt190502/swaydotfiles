#!/bin/bash
###############################
#
## Load Variables
#
###############################
. $HOME/.config/sway/scripts.d/vars.conf



###############################
#
## Handler
#
###############################
case $* in
	dropdown)
		# if selected dropdown
		if [[ ! -n "$(ps aux | grep -v grep | grep -o dropterminal)" ]]; then
			$dropterm -T dropterminal &
			sleep 0.15
			swaymsg scratchpad show 
		else
			swaymsg scratchpad show
		fi
	;;
	default)
		# open terminal
		$terminal
	;;
esac
