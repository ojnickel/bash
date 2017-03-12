#! /bin/bash
if [  $# == 0 ]; then
	echo "Usage: $0 [file] [destination} "
else
	pv $1 > $2$1
	#rm $1
fi
