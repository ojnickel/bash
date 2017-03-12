#!/bin/bash	
#container for brrip-script (reduce br to 720p or 480p) -> without error messages

if [ ! $# == 4 ]; then
	echo "Usage: $0 [outputname] [inputname] [resolution] [speed]{1 fastest - 8 slowest}"
else
	~/prog/bash/bdrip/brrip-script-1.6.sh  $1 $2 $3 $4 $5 2>/dev/null
fi
