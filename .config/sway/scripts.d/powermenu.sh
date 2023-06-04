#!/bin/bash
###############################
#
## If powermenu is open
#
###############################
[[ "$(ps aux | grep -v grep | grep -io "/bin/bash /home/.*/.config/sway/scripts.d/powermenu.sh" | wc -l)" -gt "2" ]] && killall zenity && exit



###############################
#
## Menu
#
###############################
ENTRY="$(zenity --warning \
	--title PowerMenu \
	--text '                                                POWERMENU' \
	--width 300 \
    	--extra-button Logout \
	--extra-button Lock \
    	--extra-button Suspend \
	--extra-button Reboot \
	--extra-button Shutdown \
	--ok-label 'Cancel')"
case $ENTRY in
	Logout)
		swaymsg exit
	;;
	Suspend)
		blurlock &
		sleep 1 
		systemctl suspend
	;;
	Reboot)
		systemctl reboot -i
	;;
	Shutdown)
		systemctl poweroff
	;;
	Lock)
		blurlock
	;;
	* )
		echo "No command specified..."
	;;
esac
