#!/bin/bash
#################################################
#
## Autostart Most Used Apps
#
#################################################
#~ wait 3 seconds
sleep 3

#~ run
[[ -e "$XDG_RUNTIME_DIR/.autostart" ]] && exit
while IFS= read -r line; do
	if [[ -z "$line" || "$line" =~ ^# ]]; then
		continue
	fi

	eval "$line" &
	disown
	sleep .4
done < $HOME/.autostart
touch $XDG_RUNTIME_DIR/.autostart
