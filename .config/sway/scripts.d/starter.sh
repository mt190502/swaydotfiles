#!/bin/bash
#################################################
##
#### Autostarter
##
#################################################
#~~~ starter function
startprocess() { 
	if [[ -n "$(ps aux | grep -v grep | grep -io $1)" ]]; then
		ps aux | grep -v grep | grep $1 | awk '{print $2}' | xargs kill -9
		sleep 1
	fi
	"$@"
}

#~~~ processes
startprocess /usr/libexec/kdeconnectd                                                                                                                                    &
startprocess /usr/libexec/packagekitd                                                                                                                                    &
startprocess /usr/bin/mako                                                                                                                                               &
startprocess /usr/bin/seapplet                                                                                                                                           &
startprocess /usr/bin/wl-paste -w python3 ~/.config/sway/scripts.d/clipboard.py -w                                                                                       &
startprocess /usr/bin/swayidle -w timeout 60 "~/.config/sway/scripts.d/powermenu.sh --lock" timeout 70 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' &
if [[ -e /usr/libexec/kf5/polkit-kde-authentication-agent-1 ]]; then
	XDG_CURRENT_DESKTOP=kde startprocess /usr/libexec/kf5/polkit-kde-authentication-agent-1 &
elif [[ -e /usr/lib/kf5/polkit-kde-authentication-agent-1 ]]; then
	XDG_CURRENT_DESKTOP=kde startprocess /usr/lib/kf5/polkit-kde-authentication-agent-1 &
fi

if [[ -e /usr/libexec/xdg-desktop-portal ]]; then
	startprocess /usr/libexec/xdg-desktop-portal &
elif [[ -e /usr/lib/xdg-desktop-portal ]]; then
	startprocess /usr/lib/xdg-desktop-portal &
fi

