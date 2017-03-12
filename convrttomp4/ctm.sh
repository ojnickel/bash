#! /bin/bash
	#Zeit holen
	converttime() { #file
		min=$( mediainfo $1 | grep -i duration | sed -n 1p | cut -d ":" -f 2 | cut -d " " -f 2 | cut -d "m" -f 1 )
		minsec=$(( $min * 60 ))
		sec=$( mediainfo $1 | grep -i duration | sed -n 1p | cut -d ":" -f 2 | cut -d " " -f 3 | cut -d "s" -f 1 )
		totalsec=$(( $minsec + $sec ))
	}
	process (){ #name der Proz
		    pro=$(ps cax | grep "$1")
			    if [ -z "$pro" ]; then
			       run=0
			    else
			       run=1
				fi
	}
	prozent () { #whole size, current size
		sleep 2
		run=1
		echo "run: $run"
		while (( $run == 1 ))
		do
			converttime $2
			actualtime=$totalsec
			sh /home/oswaldo/prog/bash/prozent/prozent.sh $1 $actualtime
			sleep 1
	 		process "ffmpeg"
		done
	}
	#count files
	w=0
	a=0
	f=0
	anzahl=0
	#count wmv
	for file in *.wmv 
	do
		if [ "$file" != "*.wmv" ]
		then
			(( w++ ))
			(( anzahl++ ))
			converttime $file	
			echo "$anzahl. $file -> $min:$sec ($totalsec)"
		fi
	done
	#count avi
	for file in *.avi 
	do
		if [ "$file" != "*.avi" ]
		then
			(( a++ ))
			(( anzahl++ ))
			converttime $file	
			echo "$anzahl. $file -> $min:$sec ($totalsec)"
		fi
	done
	#count wmv
	for file in *.flv
	do
		if [ "$file" != "*.flv" ]
		then
			(( f++ ))
			(( anzahl++ ))
			converttime $file	
			echo "$anzahl. $file -> $min:$sec ($totalsec)"
		fi
	done
	#total
	echo "$w wmv $a avi $f flv"
	t=$(( w + a + f ))
	echo "$t files found!"
	echo "#############################################"
	####################################
	if [ "$t" == 0 ]; then
		echo "Nothing to do. Exiting"
	else
		#nuber ofname of file
		i=1
	### wmv ####
		if [ "$w" != 0 ]; then
			for file in *.wmv
			do
			 	datei=$( echo "$file" | cut -d '.' -f 1 )
				echo "$i. $file > $datei.mp4"
				(( i++ ))
		 		ffmpeg -i "$file" $datei.mp4 > /dev/null 2>&1 
				#whole size
				converttime $file	
				whole=$totalsec
				#curent
				#prozent $whole $datei.mp4
				rm "$file"
		 done
		fi
	### avi ####
		if [ "$a" != 0 ]; then
			for file in *.avi
			do
			 	datei=$( echo "$file" | cut -d '.' -f 1 )
				echo "$i. $file > $datei.mp4"
				(( i++ ))
		 		ffmpeg -i "$file" $datei.mp4  > /dev/null 2>&1
				rm "$file"
		 done
		fi
	### flv ####
		if [ "$f" != 0 ]; then
			for file in *.flv
			do
			 	datei=$( echo "$file" | cut -d '.' -f 1 )
				echo "$i. $file > $datei.mp4"
				(( i++ ))
		 		ffmpeg -i "$file" $datei.mp4  > /dev/null 2>&1
				rm "$file"
		 done
		fi
	fi
