#!/bin/bash

declare -a audio=($( mplayer2 $1  -vo null -frames 1  2> /dev/null | grep "[mkv]" | grep audio ))
s=$( mplayer2 $1  -vo null -frames 1 | 2> /dev/null | grep "[mkv]" | grep audio | sed -n 2p | cut -d " " -f 11)
s=$( $audio | grep "[mkv]" | grep audio | sed -n 2p | cut -d " " -f 11)

echo $s
echo ${audio[1]}
echo ${audio[@]}
echo "  "
