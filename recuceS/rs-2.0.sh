#!/bin/bash	2siz
#reduce size using ffmpeg
if [ ! $# == 2 ]; then
	echo "Usage: $0 [input] [factor]"
else
	for file in *
	do
		if [[ "$file" == *.mp4 ]]
			size=`ls -hs $file`
			if [[ 
		fi
	done
	datei=$1
	tmp="datei.mp4"
	ffmpeg -i $1 -vcodec libx264 -crf $2 $tmp
	mv $tmp $datei
	size=`ls -hs $1`
fi
