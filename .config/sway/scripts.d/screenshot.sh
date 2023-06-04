#!/bin/bash
###############################
#
## Load Variables
#
###############################
. $HOME/.config/sway/scripts.d/vars.conf



###############################
#
## Program Config
#
###############################
_date=$(date +%d%m%Y_%H%M%S)
[[ -n "$(ps aux | grep -v grep | grep -ioE 'swappy|imv-wayland|grim|slurp')" ]] && killall swappy imv-wayland grim slurp
[[ -n "$(ps aux | grep -v grep | grep -Ei '/bin/bash /home/.*/.config/sway/scripts.d/screenshot.sh')" ]] && killall zenity && exit


###############################
#
## Take SS Before Run
#
###############################
takeInitialSS() {
	[[ -e "/tmp/*.png" ]] && rm /tmp/*.png

	for a in $(swaymsg -t get_outputs | jq -r ".[].name"); do
		grim ${cursor:+-c} -o $a /tmp/$a.png
		swaymsg for_window "[title=\"imv(.*)$a.png\"]" move to output $a
		swaymsg for_window "[title=\"imv(.*)$a.png\"]" fullscreen true
		imv-wayland /tmp/$a.png &
	done
}



###############################
#
## Open Photo Editor (swappy)
#
###############################
photoEditor() {
  #showEditor=$(zenity --list  --title "Screenshot" --column "Show Editor" yes no)
	[[ "$showEditor" == "yes" ]] && swappy -f /tmp/$@ -o /tmp/$@ || echo "->"
}



###############################
#
## Timeout (if selected)
#
###############################
timeoutBeforeSS() {
	timeout="$(zenity --title Screenshot \
	--text 'Full Screenshot' \
	--scale --value 3 --max-value 50 )"
	[[ ! -z $timeout ]] && sleep $timeout || exit
}





###############################
#
## Take Rectangular SS
#
###############################
rectangularSS() {
	slurpout=$(slurp)
	if [[ ! -n $slurpout ]]; then
	  notify-send "Coordinate not specified, aborting..."
	  killall swappy imv-wayland grim slurp
	  exit
	fi
	grim ${cursor:+-c} -g "$slurpout" - | tee /tmp/rectangularss.png 1>/dev/null
	killall imv-wayland
	echo
}





###############################
#
## Multiple Screen
#
###############################
isMultiple(){
	for a in $(swaymsg -t get_outputs | jq -r ".[].name"); do
		files="$files /tmp/$a.png"
	done

	pushd /tmp
	convert +append $files ss.png
	popd
}





###############################
#
## Copy Image to Clipboard
#
###############################
copyToClipboard() {
	cat /tmp/$@ | wl-copy && notify-send "The photo has been taken" || notify-send "The photo could not be taken"
	rm /tmp/*.png
}





###############################
#
## Save Image to Directory
#
###############################
saveToDirectory() {
	mv /tmp/$@ $imageDirectory/IMG_$_date.png && notify-send "The photo has been taken" || notify-send "The photo could not be taken"
	rm /tmp/*.png
}





###############################
#
## Handler
#
###############################
rectangular() {
ENTRY2="$(zenity --warning \
	--title Screenshot \
	--text 'Rectangular Screenshot' \
	--width 300 \
       	--extra-button "Timeout&Save" \
	--extra-button "Timeout&Copy" \
	--extra-button "Save" \
       	--extra-button "Copy" \
	--ok-label 'Cancel' )"

[[ "$ENTRY2" == "Timeout&Save" ]] && timeoutBeforeSS && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && saveToDirectory "rectangularss.png"
[[ "$ENTRY2" == "Timeout&Copy" ]] && timeoutBeforeSS && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
[[ "$ENTRY2" == "Save" ]] && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && saveToDirectory "rectangularss.png"
[[ "$ENTRY2" == "Copy" ]] && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
}


full() {
ENTRY2="$(zenity --warning \
	--title Screenshot \
	--text 'Full Screenshot' \
	--width 300 \
       	--extra-button "Timeout&Save" \
	--extra-button "Timeout&Copy" \
	--extra-button "Save" \
       	--extra-button "Copy" \
	--ok-label 'Cancel' )"

[[ "$ENTRY2" == "Timeout&Save" ]] && timeoutBeforeSS && takeInitialSS && isMultiple && photoEditor "ss.png" && saveToDirectory "ss.png"
[[ "$ENTRY2" == "Timeout&Copy" ]] && timeoutBeforeSS && takeInitialSS && isMultiple && photoEditor "ss.png" && copyToClipboard "ss.png"
[[ "$ENTRY2" == "Save" ]] && takeInitialSS && isMultiple && photoEditor "ss.png" && saveToDirectory "ss.png"
[[ "$ENTRY2" == "Copy" ]] && takeInitialSS && isMultiple && photoEditor "ss.png" && copyToClipboard "ss.png"
}

case $1 in
	rec)
		takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
	;;
	full)
		takeInitialSS && isMultiple && photoEditor "ss.png" && copyToClipboard "ss.png"
	;;
	*)
		ENTRY1="$(zenity --warning \
		       	--title Screenshot \
			--text 'Screenshot' \
			--width 300 \
		       	--extra-button Rectangular \
			--extra-button Full \
		       	--ok-label 'Cancel' )"
		[[ "$ENTRY1" == "Rectangular" ]] && rectangular
		[[ "$ENTRY1" == "Full" ]] && full
	;;
esac
