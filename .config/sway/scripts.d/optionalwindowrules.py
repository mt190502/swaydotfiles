#!/bin/python3
import os

with open(f"{os.environ['HOME']}/.config/sway/scripts.d/vars.conf") as f:
    xpos = int(os.popen("xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f1").read().strip("\n"))
    ypos = int(os.popen("xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f2").read().strip("\n"))
    numberOfMonitors = int(os.popen("swaymsg -t get_outputs | jq -r '.[].name' | wc -l").read().strip("\n"))


rules = {
    0: {
        "app_id": "zenity",
        "title": "PowerMenu",
        "rules": [
            "floating enable",
            f"move position {int((xpos / numberOfMonitors) -595)} 0"
        ]
    },
    1: {
        "app_id": "zenity",
        "title": "Screenshot",
        "rules": [
            "floating enable",
            f"move position {int((xpos / numberOfMonitors) -635)} 0"
        ]
    },
    2: {
        "app_id": "kitty",
        "title": "dropterminal",
        "rules": [
            "move container to scratchpad",
            f"move up {int((ypos / 4) - 14)}",
            f"resize set {int(xpos / (numberOfMonitors + 2))} {int(ypos / 2)}"
        ]
    },
    3: {
        "app_id": "kitty",
        "title": "nmtui",
        "rules": [
            "floating enable",
            f"resize set 1366 768"
        ]
    },
    4: {
        "title": "^Open File$",
        "rules": [
            "floating enable",
            f"resize set {int(xpos / (numberOfMonitors + 2))} {int(ypos / 2)}",
            "move position center"
        ]
    },
    5: {
        "app_id": "org.freedesktop.impl.portal.desktop.kde",
        "rules": [
            "floating enable",
            f"resize set {int(xpos / (numberOfMonitors + 2))} {int(ypos / 2)}",
            "move position center"
        ]
    },
    6: {
        "window_role": "GtkFileChooserDialog",
        "rules": [
            "floating enable",
            f"resize set {int(xpos / (numberOfMonitors + 2))} {int(ypos / 2)}",
            "move position center"
        ]
    },
}


###############################
#
## Run
#
###############################
for a in range(len(rules)):
    args = []
    action = []
    for b in rules[a]:
        if b != "rules":
            args.append(f"{b}=\"{rules[a][b]}\"")
        else:
            action.append(rules[a][b])

    for c in action[0]:
        os.system(f"swaymsg for_window \'[{' '.join(args)}]\' {c}")
