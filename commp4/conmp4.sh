#!/bin/bash	

if [ ! $# == 3 ]; then
	echo "Usage: $0 [video] [audio] [subs]"
else
	h264="$1.264"
	vmp4="$1.mp4"
	echo "================"
	echo -n "Creating mp4... "
	`MP4Box -fps 25 -add $h264 $2 $3 $vmp4`
	echo -n "done" 
fi
