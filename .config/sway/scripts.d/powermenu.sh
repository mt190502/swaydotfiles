#!/bin/bash
#################################################
##
#### PowerMenu
##
#################################################
#~~~ variables
WAYLAND_DISPLAY=wayland-1

#~~~ lock function
blurlock() {
    [[ -n "$(ps aux | grep -v grep | grep swaylock)" ]] && exit
    for output in $(swaymsg -t get_outputs | jq -r '.[].name'); do
        image=/tmp/$output-lock
	[[ -e $image ]] && rm $image
        grim -l 1 -o $output $image.png
        convert -blur 0x10 $image.png $image-blurred.png
        args="$args --image $output:$image-blurred.png"
    done
    touch $HOME/.cache/swaylock.lock
    WAYLAND_DISPLAY=$WAYLAND_DISPLAY swaylock $args
    rm -f $HOME/.cache/swaylock.lock
}

#~~~ menu
[[ "$@" == "--lock" ]] && { blurlock; exit 0; }
[[ "$@" == "--suspend" ]] && { blurlock; sleep 2; systemctl suspend; exit 0; }
[[ "$@" == "--daemonize" ]] && {
	while true; do
		if [[ -f "$HOME/.cache/swaylock.lock" ]] && [[ -z "$(ps aux | grep -v grep | grep swaylock)" ]]; then
			blurlock
		fi
		sleep 1
	done
}

MODE=$(swaynag -t wpgtheme -m PowerMenu -Z Shutdown 'echo 0' -Z Reboot 'echo 1' -Z Suspend 'echo 2' -Z Hibernate 'echo 3' -Z Lock 'echo 4' -Z Logout 'echo 5')
[[ ! -n "$MODE" ]] && exit
CONFIRM=$(swaynag -t wpgtheme -m Confirm? -Z No 'echo no' -Z Yes 'echo yes')
[[ $CONFIRM != "yes" ]] && exit
case $MODE in
    0)
        systemctl poweroff
    ;;
    1)
        systemctl reboot -i
    ;;
    2)
        touch $HOME/.cache/swaylock.lock
	sleep 1
        systemctl suspend
    ;;
    3)
        touch $HOME/.cache/swaylock.lock
	sleep 1
        systemctl hibernate
    ;;
    4)
        touch $HOME/.cache/swaylock.lock
    ;;
    5)
	rm $XDG_RUNTIME_DIR/.autostart
        swaymsg exit
    ;;
    *)
        echo "No command specified..."
    ;;
esac
