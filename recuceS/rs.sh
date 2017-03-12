#!/bin/bash	
#reduce size using ffmpeg
if [ ! $# == 2 ]; then
	echo "Usage: $0 [input] [factor]"
else
	datei=$1
	tmp="datei.mp4"
	ffmpeg -i $1 -vcodec libx264 -crf $2 $tmp
	mv $tmp $datei
	size=$(ls -hs $1)
	echo "-----------------------------------------------\n$1 -> $size Mb"
fi
