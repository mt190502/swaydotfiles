#!/bin/bash
#################################################
##
#### Tmux server
##
#################################################
while true; do
	[[ -z "$(tmux ls | grep daemonmodetmux)"   ]] && { cd $HOME && tmux new-session -ds daemonmodetmux; }
	[[ -z "$(tmux ls | grep dropterminaltmux)" ]] && { cd $HOME && tmux new-session -ds dropterminaltmux; }
	sleep 1
done
