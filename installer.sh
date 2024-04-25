#################################################
##
#### MTAHA's dotfile installer
##
#################################################
FGRED="\e[0;31m"
FGREN="\e[0;32m"
FGYEL="\e[0;33m"
FGRES="\e[0;39m"

PACKAGES=(
	'app:BlueZ and Libraries:bluetoothctl'
	'app:Brightness Control:brightnessctl'
	'app:cURL:curl'
	'app:FFMpeg:ffmpeg'
	'app:FFMpeg Thumbnailer:ffmpegthumbnailer'
	'app:Gnome Keyring Daemon:gnome-keyring-daemon'
	'app:Grim Screenshot Tool:grim'
	'app:Htop Task Manager:htop'
	'app:ImageMagick:convert'
	'app:Imv Image Viewer:imv-wayland'
	'app:JSON parser:jq'
	'app:Kitty Terminal:kitty'
	'app:LM Sensors:sensors'
	'app:LXDE Theme Manager:lxappearance'
	'app:Mako Notifier:mako'
	'app:Network Manager TUI:nmtui'
	'app:Player Control:playerctl'
	'app:Polkit:pkexec'
	'app:Pulseaudio Control:pactl'
	'app:Pulseaudio Volume Control:pavucontrol'
	'app:Python3 PiP:pip'
	'app:QT5 Configuration Tool:qt5ct'
	'app:Slurp Area Selector:slurp'
	'app:SQLite:sqlite3'
	'app:Swappy Image Editor:swappy'
	'app:SwayWM:sway'
	'app:Sway Background:swaybg'
	'app:Sway Idle:swayidle'
	'app:Sway Lock:swaylock'
	'app:Tesseract OCR:tesseract'
	'app:Translate Shell:trans'
	'app:WayBar:waybar'
	'app:Wayland Clipboard:wl-copy'
	'app:Wayland NightLight:wlsunset'
	'app:Wofi Menu:wofi'
	'app:WType:wtype'
	'lib:LibAppIndicator:libappindicator.so.*'
	'lib:LibDBusMenu:libdbusmenu-glib.so.*'
	'lib:QT5 Styleplugins:libqgtk2.so*'
	'lib:Polkit KDE:polkit-kde-authentication-agent-1'
	'lib:XDG Desktop Portal:xdg-desktop-portal'
	'lib:XDG Desktop Portal KDE:xdg-desktop-portal-kde'
	'lib:XDG Desktop Portal WLR:xdg-desktop-portal-wlr'
)

CONFIGDIRS=(
	'.config/alacritty'
	'.config/environment.d'
	'.config/fontconfig'
	'.config/kitty'
	'.config/Kvantum'
	'.config/mako'
	'.config/Mangohud'
	'.config/neofetch'
	'.config/nvim'
	'.config/qt5ct'
	'.config/qt6ct'
	'.config/swappy'
	'.config/sway'
	'.config/swaylock'
	'.config/swaynag'
	'.config/tmux'
	'.config/waybar'
	'.config/wofi'
	'.config/wpg'
)

currdate=$(date +%Y%m%d_%H%M%S)
PATH="$HOME/.local/bin:$PATH"
export PATH



checkpackages() {
	missedpacks=0
	[[ -n "$@" ]] || exit 1
	local pkgs=("$@")
	for a in "${pkgs[@]}"; do
		type=$(echo $a | cut -d ':' -f1)
		file=$(echo $a | cut -d ':' -f3)
		name=$(echo $a | cut -d ':' -f2)
		formattedname=$(printf "%-*s %*s" "25" "$name" "40" "(file: $file)")
		[[ "$type" == "app" ]] && [[ ! -n "$(command -v $file)" ]] && echo -e "Please install ${FGYEL}\"$formattedname\"${FGRES} before proceeding..." && missedpacks=$(($missedpacks+1))
		[[ "$type" == "lib" ]] && [[ ! -n $(find /usr/lib* -iname "$file" 2>/dev/null | xargs echo) ]] && echo -e "Please install ${FGYEL}\"$formattedname\"${FGRES} before proceeding..." && missedpacks=$(($missedpacks+1))
	done
	[[ $missedpacks -ge 1 ]] && exit 1
}



install_dotfiles() {
	[[ -n "$@" ]] || exit 1
	local dirs=("$@")
	for a in "${dirs[@]}"; do
		[[ -e $HOME/$a ]] && continue
		printf "%-12s %-50s -> %-50s\n" "Installing" "$(pwd)/$a" "$HOME/.config"
		cp -r $(pwd)/$a $HOME/.config/
	done
}



remove_dotfiles() {
	[[ -n "$@" ]] || exit 1
	local dirs=("$@")
	for a in "${dirs[@]}"; do
		[[ ! -e $HOME/$a ]] && continue
		printf "%-12s %-50s -> %-50s\n" "Removing" "$HOME/$a" "/dev/null"
		rm -rf $HOME/$a
	done
}



backup_dotfiles() {
	[[ -n "$@" ]] || exit 1
	local dirs=("$@")
	for a in "${dirs[@]}"; do
		[[ ! -e $HOME/$a ]] && continue
		[[ ! -d $HOME/.dotbackups ]] && mkdir -p $HOME/.dotbackups
		mkdir -p $HOME/.dotbackups/$currdate
		echo $currdate > $HOME/.dotbackups/lastbackupdate
		printf "%-12s %-50s -> %-50s\n" "Backing up" "$HOME/$a" "$HOME/.dotbackups/$currdate/"
		mv $HOME/$a $HOME/.dotbackups/$currdate/
	done
}



restore_dotfiles() {
	[[ ! -e $HOME/.dotbackups/lastbackupdate ]] && echo "Backup dir is empty" && exit 1
	backupfoldername=$(cat $HOME/.dotbackups/lastbackupdate)
	printf "%-12s %-50s -> %-50s\n" "Restoring" "$HOME/.dotbackups/$backupfoldername/*" "$HOME/.config/"
	cp -r $HOME/.dotbackups/$backupfoldername/* $HOME/.config/
}



other_settings() {
	[[ ! -d "$(pwd)/logs" ]] && mkdir "$(pwd)/logs"
	printf "%-12s %-50s -> %-50s\n" "Installing" "Some Dependencies" "to Local"
	python3 -m pip install pillow pywal --user --break-system-packages &>>$(pwd)/logs/log_$currdate.txt
	python3 -m pip install wpgtk hashlib json sqlite3 --user --break-system-package &>>$(pwd)/logs/log_$currdate.txt
	wpg-install.sh -gi &>>$(pwd)/logs/log_$currdate.txt
	printf "%-12s %-50s -> %-50s\n" "Installing" "FlatColor configs" "~/.local/share/themes/FlatColor"
	cp bin/gtk2.0  $HOME/.local/share/themes/FlatColor/gtk-2.0/gtkrc    &>>$(pwd)/logs/log_$currdate.txt
	cp bin/gtk3.0  $HOME/.local/share/themes/FlatColor/gtk-3.0/gtk.css  &>>$(pwd)/logs/log_$currdate.txt
	cp bin/gtk3.20 $HOME/.local/share/themes/FlatColor/gtk-3.20/gtk.css &>>$(pwd)/logs/log_$currdate.txt
	printf "%-12s %-50s -> %-50s\n" "Installing" "Fonts" "~/.fonts"
	[[ ! -d $HOME/.fonts ]] && mkdir $HOME/.fonts
	cp bin/*.{ttf,otf} $HOME/.fonts/
	fc-cache -fv &>>$(pwd)/logs/log_$currdate.txt
	printf "%-12s %-50s -> %-50s\n" "Installing" "startsway command" "/usr/local/bin"
	sudo tee <<-EOF /usr/local/bin/startsway &>/dev/null
export \$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
set PATH \$HOME/.config/sway/scripts.d/bin:\$PATH
dbus-update-activation-environment --systemd --all
sway
	EOF
	sudo chmod +x /usr/local/bin/startsway
	printf "%-12s %-50s -> %-50s\n" "Installing" "KDE File Picker Patch" "/usr/share/xdg-desktop-portal/portals/10-kdefilechooser.portal"
	sudo tee <<-EOF /usr/share/xdg-desktop-portal/portals/10-kdefilechooser.portal &>/dev/null
[portal]
DBusName=org.freedesktop.impl.portal.desktop.kde
Interfaces=org.freedesktop.impl.portal.FileChooser;
UseIn=GNOME;
	EOF

	printf "%-12s %-50s -> %-50s\n" "Writing" "Monitor Settings" "in configs"
	if [[ "$(swaymsg -t get_outputs | jq -r '.[].name' | wc -l)" == 1 ]]; then
		monitorSocketName=$(swaymsg -t get_outputs | jq -r '.[].name')
		sed -i "s/SCREEN1/$monitorSocketName/g" $HOME/.config/sway/config.d/environments
		sed -i "s/SCREEN2/$monitorSocketName/g" $HOME/.config/sway/config.d/environments
		sed -i "s/SCREEN1/$monitorSocketName/g" $HOME/.config/waybar/config
		sed -i "s/SCREEN2/$monitorSocketName/g" $HOME/.config/waybar/config
	elif [[ "$(swaymsg -t get_outputs | jq -r '.[].name' | wc -l)" == 2 ]]; then
		firstMonitorSocketName=$(swaymsg -t get_outputs | jq -r '.[].name' | head -n 1)
		secondMonitorSocketName=$(swaymsg -t get_outputs | jq -r '.[].name' | tail -n 1)
		sed -i "s/SCREEN1/$firstMonitorSocketName/g" $HOME/.config/sway/config.d/environments
		sed -i "s/SCREEN2/$secondMonitorSocketName/g" $HOME/.config/sway/config.d/environments
		sed -i "s/SCREEN1/$firstMonitorSocketName/g" $HOME/.config/waybar/config
		sed -i "s/SCREEN2/$secondMonitorSocketName/g" $HOME/.config/waybar/config
	fi

	printf "%-12s %-50s -> %-50s\n" "Linking" "Configs" "~/.config/wpg/templates"
	ln -sf $HOME/.config/dolphinrc                                              $HOME/.config/wpg/templates/dolphin
	ln -sf $HOME/.config/mako/config                                            $HOME/.config/wpg/templates/mako
	ln -sf $HOME/.config/sway/config.d/colors                                   $HOME/.config/wpg/templates/sway
	ln -sf $HOME/.config/swaylock/config                                        $HOME/.config/wpg/templates/swaylock
	ln -sf $HOME/.config/swaynag/config                                         $HOME/.config/wpg/templates/swaynag
	ln -sf $HOME/.config/waybar/style.css                                       $HOME/.config/wpg/templates/waybar
	ln -sf $HOME/.config/wofi/style.css                                         $HOME/.config/wpg/templates/wofi
	ln -sf $HOME/.config/wpg/wallpapers/$(basename ~/.config/wpg/wallpapers/*)  $HOME/.config/wpg/.current

	chmod +x $HOME/.config/sway/scripts.d/*.{py,sh}
	chmod +x $HOME/.config/sway/scripts.d/bin/*
}


case $@ in
	install|-i|--install)
		checkpackages "${PACKAGES[@]}"
		backup_dotfiles "${CONFIGDIRS[@]}"
		install_dotfiles "${CONFIGDIRS[@]}"
		other_settings
	;;
	remove|-r|--remove)
		remove_dotfiles "${CONFIGDIRS[@]}"
	;;
	backup|-b|--backup)
		backup_dotfiles "${CONFIGDIRS[@]}"

	;;
	restore|-R|--restore)
		remove_dotfiles "${CONFIGDIRS[@]}"
		restore_dotfiles
	;;
	*)
		echo -e "${FGRED}No command specified...${FGRES}"
		exit
	;;
esac
