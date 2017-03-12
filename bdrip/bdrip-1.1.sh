#!/bin/bash	
#container for brrip-script (reduce br to 720p or 480p) -> without error messages

if [ ! $# == 5 ]; then
	echo "Usage: $0 [outputname] [inputname] [dimensions] [speed] [pass]"
else
	~/prog/bash/bdrip/brrip-script-1.2.sh  $1 $2 $3 $4 $5 2>/dev/null
fi
