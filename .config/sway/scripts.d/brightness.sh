#!/bin/bash
#############################
#
## Load Variables
#
##############################
. $HOME/.config/sway/scripts.d/vars.conf



#############################
#
## If backlight device
## exists on path
#
##############################
if [[ -d /sys/class/backlight/$backlightDevice/ ]] ; then
	case $1 in
	get )
		# get brightness level
		echo "  $(brightnessctl | grep -o '(.*)' | tr -dc '[0-9]')"
	;;
	up )
		# increase brightness
		brightnessctl set +5%
	;;
	down )
		# if the brightness level is greater than backlightBaseLimit
		if [[ ! "$(brightnessctl | grep -o '(.*)' | tr -dc '[0-9]')" -le "$backlightBaseLimit" ]]	; then
			# decrease brightness
			brightnessctl set 5%-
		fi
	;;
	esac
fi

