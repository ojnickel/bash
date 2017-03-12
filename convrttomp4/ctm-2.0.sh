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
		webm=0
		mpg=0
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
			if [[ "$file" == *"$4" ]]
			then
				(( webm++ ))
				echo "found $file"
			fi
			if [[ "$file" == *"$5" ]]
			then
				(( mpg++ ))
				echo "found $file"
			fi
		done
		anzahl=$(( $webm + $wmv + $avi + $flv + $mpg))
	}

	m=".mpg"
	w=".wmv"
	a=".avi"
	f=".flv"
	we=".webm"
	count $w $a $f $we $m
	cho "total: $anzahl files"
	echo "$wmv wmv, $avi avi, $flv flv, $webm webm $mpg mpg"
	#co
	currentfile=1
	#for (( i=0; i < $total; i++ ))i
	for file in *
	do
		if [[ "$file" == *"$w" ]] || [[ "$file" == *"$a" ]] || [[ "$file" == *"$m" ]] || [[ "$file" == *"$f" ]] || [[ "$file" == *".FLV" ]] || [[ "$file" == *"$we" ]]
		then
			#laenge
			laenge=${#file}
			#position vor suffix
			if [[ "$file"  == *"$we" ]]; then
				pos=$(( $laenge - 5 ))
			else
				pos=$(( $laenge - 4 ))
			fi
			l="$file"
			datei=${l:0:pos}
			ziel="$datei.mp4"
		#	converttime "$file"
			echo "($currentfile/$anzahl) $file > $ziel "
			avconv -i "$file" -strict experimental "$ziel" > /dev/null 2>&1 
			rm "$file"
			#prozent $anzahl $currentfile "$ziel"
			(( currentfile++ ))
		fi
	done
