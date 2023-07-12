#!/bin/bash
eval $(/usr/bin/gnome-keyring-daemon --start --foreground --components=gpg,pkcs11,secrets,ssh)

systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
hash dbus-update-activation-environment 2>/dev/null
dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

