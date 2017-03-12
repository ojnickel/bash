#!/bin/bash	
#container for brrip-script (reduce br to 720p or 480p) -> without error messages

if [ ! $# == 3 ]; then
	echo "Usage: $0 [outputname] [inputname] [dimensions]"
else
	on=$1
	in=$2
	di=$3
	~/prog/bash/bdrip/brrip-script.sh  $1 $2 $3 2>/dev/null
fi
