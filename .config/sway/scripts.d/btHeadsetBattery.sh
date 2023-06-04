#!/bin/bash
#############################
#
## Load Variables
#
##############################
. $HOME/.config/sway/scripts.d/vars.conf




#############################
#
## Handler
#
##############################
btDeviceID="$(bluetoothctl devices | awk '{print $2}')"
IDv2="$(echo $btDeviceID | sed 's/:/_/g')"

if [[ -n "$(bluetoothctl info $btDeviceID | grep -B8 -o 'Connected: yes')" ]]; then
	btDeviceUpowerPath="$(upower -e | grep $IDv2)"
	upowerOutput="$(upower -i $btDeviceUpowerPath | grep percentage | awk '{print $2}')"
	if [[ -n "$upowerOutput" ]]; then
		prefixes=('' '' '' '' '' '' '' '' '' '' '')
		prefix=${prefixes[$(( $(echo $upowerOutput | tr -dc '[:digit:]') / 10))]}
		echo "|     $prefix  $upowerOutput    "
	else
		echo "|     ?   X    "
	fi
fi









