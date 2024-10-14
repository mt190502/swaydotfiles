#!/bin/bash
#################################################
##
#### Screen setup for multi monitor setup
##
#################################################
IFS=$'\n' read -r -d '' -a outputs <<< "$(swaymsg -t get_outputs | jq -r '.[].name')"

if [[ "${#outputs[@]}" == "1" ]]; then
  sed -i "s/set \$scr1.*/set \$scr1          ${outputs[0]}/g" $HOME/.config/sway/config.d/environments
  sed -i "s/set \$scr2.*/set \$scr2          ${outputs[0]}/g" $HOME/.config/sway/config.d/environments
  for a in $(seq 1 8); do
    sed -i "s/\"$a\".*/\"$a\"                    : [\"${outputs[0]}\"],/g" $HOME/.config/waybar/config
  done
elif [[ "${#outputs[@]}" == "2" ]]; then
  sed -i "s/set \$scr1.*/set \$scr1          ${outputs[1]}/g" $HOME/.config/sway/config.d/environments
  sed -i "s/set \$scr2.*/set \$scr2          ${outputs[0]}/g" $HOME/.config/sway/config.d/environments
  sed -i "s/output \$scr1 pos.*/output \$scr1 pos           0       0/g" $HOME/.config/sway/config.d/outputs
  sed -i "s/output \$scr2 pos.*/output \$scr2 pos           $(swaymsg -t get_outputs | jq -r '.[1].rect.width')    0/g" $HOME/.config/sway/config.d/outputs
  for a in $(seq 1 8); do
    if [[ $a -le 4 ]]; then
      sed -i "s/\"$a\".*/\"$a\"                    : [\"${outputs[1]}\"],/g" $HOME/.config/waybar/config
    else 
      sed -i "s/\"$a\".*/\"$a\"                    : [\"${outputs[0]}\"],/g" $HOME/.config/waybar/config
    fi
  done
fi
