#! /bin/bash
	#count files
	i=0
	for file in *.mp4
	do
		(( i++ ))
	done
	echo "$i files found!"
	if [ -z "$i" ]; then
		echo "exiting"
	else
		i=1
		for file in *.mp4
		do
		 	datei=$( echo "$file" | cut -d '.' -f 1 )
			echo "$i. $datei"
			(( i++ ))
		 	ffmpeg -i "$file" $datei.mp4 
		 	rm "$file"
		 done
	fi
