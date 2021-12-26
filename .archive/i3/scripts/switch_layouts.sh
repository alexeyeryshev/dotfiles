#!/usr/bin/env bash
current_layout=$(~/.config/i3/tools/xkblayout-state/xkblayout-state print %s | awk '{print $0}')
# layout_to_set="fr"
# if [ "$current_layout" == "fr" ]; then
#     layout_to_set="ru"
# elif [ "$current_layout" == "ru" ]; then
# elif [ "$current_layout" == "ru" ]; then
#     layout_to_set="us -variant intl"
# elif [ "$current_layout" == "us" ]; then
#     layout_to_set="fr"
# fi
layout_to_set="us"
if [ "$current_layout" == "ru" ]; then
    layout_to_set="us"
elif [ "$current_layout" == "us" ]; then
    layout_to_set="ru"
fi
echo $layout_to_set
setxkbmap -model pc105 -layout $layout_to_set -option caps:escape
pkill -RTMIN+1 i3blocks
