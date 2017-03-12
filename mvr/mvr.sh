#! /bin/bash
if [  $# == 0 ]; then
	echo "Usage: $0 [destination} [file1]..."
else
	#number of files to be copied
	destfolder="$1"
	for file in "$@"
	do
		if  [ ! "$file" == "$1" ] 
		then
			dest=$destfolder$file
			pv $file > "$1""$file"
		#	rm $file
		fi
	done
fi
