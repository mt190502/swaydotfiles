#!/bin/bash
. $HOME/.config/sway/scripts.d/vars.conf

#############################
#
## Program Starter
#
#############################
startprogram() {
	if [[ -n """$(ps aux | grep -v grep | grep -io "$1")""" ]]; then
		killall "$1"
		sleep 1
	fi
	$@
}


#############################
#
## Programs
#
#############################
# KDE Connect Daemon
startprogram /usr/libexec/kdeconnectd &

# PackageKit Daemon
startprogram /usr/libexec/packagekitd &

# Mako Notifier
startprogram mako &

# Clipboard Manager
startprogram wl-paste -t text -w python3 $HOME/.config/sway/scripts.d/clipboard.py -w &

# dnfdragora
startprogram dnfdragora-updater &

# SELinux Applet
startprogram seapplet &

# Authentication Agent
if [[ -e $AGENT1 ]]; then
	startprogram $AGENT1 &
elif [[ -e $AGENT2 ]]; then
	startprogram $AGENT2 &
fi

# Portal
if [[ -e $PORTAL1 ]]; then
	startprogram $PORTAL1 &
elif [[ -e $PORTAL2 ]]; then
    startprogram $PORTAL2 &
fi
