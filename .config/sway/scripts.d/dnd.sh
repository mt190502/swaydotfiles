#!/bin/bash
#################################################
##
#### Mako Do-Not-Disturb mode toggler
##
#################################################

togglemode() {
	if [ "$(makoctl mode)" == "dnd" ]; then
		makoctl mode -s default &>/dev/null
		rm -f /run/user/$(id -u)/dnd_enabled 
	else
		makoctl mode -s dnd &>/dev/null
		echo enabled > /run/user/$(id -u)/dnd_enabled
	fi
}

status() {
	if [[ ! -e /run/user/$(id -u)/dnd_enabled ]]; then
		_status="DND Inactive"
		output="{\"text\": \"\", \"alt\": \" ${_status}\", \"tooltip\": \" ${_status}\"}"
	else
		_status="DND Active"
		output="{\"text\": \"\", \"alt\": \" ${_status}\", \"tooltip\": \" ${_status}\"}"
	fi
	echo $output
}


main() {
	case $@ in
		status)
			status
		;;
		*)
			togglemode
		;;
	esac
}


main "$@"
