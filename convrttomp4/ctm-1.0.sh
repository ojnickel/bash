#! /bin/bash
	#Zeit holen
	converttime() { #file
		min=$( mediainfo $1 | grep -i duration | sed -n 1p | cut -d ":" -f 2 | cut -d " " -f 2 | cut -d "m" -f 1 )
		minsec=$(( $min * 60 ))
		sec=$( mediainfo $1 | grep -i duration | sed -n 1p | cut -d ":" -f 2 | cut -d " " -f 3 | cut -d "s" -f 1 )
		totalsec=$(( $minsec + $sec ))
	}
	process (){ #name der Proz
#		    pro=$(ps cax | grep "$1")
				
				pro=$( mediainfo $1 | grep -i duration | sed -n 1p | cut -d ":" -f 2 | cut -d " " -f 2 | cut -d "m" -f 1 )
			    if [ -z "$pro" ]; then
			       run=0
			    else
			       run=1
				fi
	}
	prozent () { #whole size, current size, current filenme
		sleep 2
		run=1
		while (( $run == 1 ))
		do
			sh  /home/oswaldo/prog/bash/convrttomp4/prozent.sh $1 $2 "$3"
			sleep 1
	 		process "$3"
		done
	}
	#count files
	count () {
		wmv=0
		avi=0
		flv=0
		#total=$( ls | wc -l )
		#for (( i=0; i<total; i++ ))
		for file in *
		do
			if [[ "$file" == *"$1" ]]
			then
				(( wmv++ ))
				echo "found $file"
			fi
			if [[ "$file" == *"$2" ]]
			then
				(( avi++ ))
				echo "found $file"
			fi
			if [[ "$file" == *"$3" ]] || [[ "$file" == *".FLV" ]]
			then
				(( flv++ ))
				echo "found $file"
			fi
		done
		anzahl=$(( $wmv + $avi + $flv ))
	}

	w=".wmv"
	a=".avi"
	f=".flv"
	count $w $a $f
	echo "total: $anzahl files"
	echo "$wmv wmv, $avi avi, $flv flv"
	#co
	currentfile=1
	#for (( i=0; i < $total; i++ ))i
	for file in *
	do
		if [[ "$file" == *"$w" ]] || [[ "$file" == *"$a" ]] || [[ "$file" == *"$f" ]] || [[ "$file" == *".FLV" ]]
		then
			#laenge
			laenge=${#file}
			#position vor suffix
			pos=$(( $laenge - 4 ))
			l="$file"
			datei=${l:0:pos}
			ziel="$datei.mp4"
		#	converttime "$file"
			echo "($currentfile/$anzahl) $file > $ziel "
			ffmpeg -i "$file" "$ziel" > /dev/null 2>&1 
			rm "$file"
			#prozent $anzahl $currentfile "$ziel"
			(( currentfile++ ))
		fi
	done
