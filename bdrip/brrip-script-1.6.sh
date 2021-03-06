#!/bin/bash																							
#program to reduce 1080p to given resolution (720p or 480p)
###############################################################################
# für prozent
bitrate_c () { #old size, new siize
	diference=$(( $2 - $1 ))
	if [ $diference -lt 1024 ]; then
		bit=$diference"KB/s"
	else
		bit=$diference"MB/s"
	fi
}
fps () { #film
	fps=`mkvinfo $1 | grep -i bilder | sed -n 1p |  cut -d "(" -f 2 | cut -d " " -f 1`
}

preset () { #nr. preset
	case $1 in
		1)
			preset="ultrafast";;
		2)
			preset="superfast";;
		3)
			preset="veryfast";;
		4)
			preset="faster";;
		5)
			preset="fast";;
		6)
			preset="medium";;
		7)
			preset="slow";;
		8)
			preset="veryslow";;
	esac
}
size_wav () { #sample rate,#kanäle,bits für sample,länge(sekunden)
	ss=$( mplayer2 $1  -vo null -frames 1 | grep AUDIO | cut -d " " -f 2)
	sample=$(echo "scale=1; $ss / 1000" | bc )
	kanal=$( mplayer2 $1  -vo null -frames 1 | grep AUDIO | cut -d " " -f 4)
	bitsample=$( mplayer2 $1  -vo null -frames 1 | grep AUDIO | cut -d " " -f 6 | cut -d "s" -f 2 | cut -d "l" -f 1)
	bs=$(echo "scale=1; $bitsample / 8" | bc )
	sizea=$(echo "scale=1;  $sample * $kanal * $bs * $2 * 97 / 100" | bc)
	#97%
	round $sizea
	sizea=$rund
}

round () { #whole
	#damit nachkomma nicht verloren geht
	z=$(echo "scale=2; $1 * 1000" | bc )
	#zahl_zu_runden=$(( $c * 10.0 ))
	ohne_komas=${z/.*}
	#nachkomma-Zahl
	nach_komma=$(( $ohne_komas % 10 ))

	if [ $nach_komma == 0 ]; then
		rund=$(( $ohne_komas/1000 ))
	else
		rund=$(( $ohne_komas - $nach_komma ))
		#wieder normal
		(( rund /= 1000 ))
		#zur nachsten nummer
		(( rund++ ))
	fi
}
convert_time (){ #sekunde

#angegebene zeit (sekunden) nach stunden suchen und die zeit - diese stunden berechnen. Übriges für min und so weiter
	hour=$(( $1 / 3600 ))
	minus=$(( $hour * 3600 ))
	zeit=$(( $1 - $minus ))
	
	min=$(( $zeit / 60 ))
	if [ $min -lt  10 ];then
		minuten=0$min
	else
		minuten=$min
	fi
	minus=$(( $min * 60 ))
	zeit=$(( $zeit - $minus ))

	sec=$zeit
	if [ $sec -lt  10 ];then
		sek=0$sec
	else
		sek=$sec
	fi
}


#größe setzen
mkv_laenge () { #film
#	laufzeit=`mkvinfo $1 | grep  Dauer | cut -d " "  -f 4 | cut -d "s" -f 1`
	laufzeit=$( mkvinfo $1 | grep  Dauer | cut -d " "  -f 4 | cut -d "s" -f 1 | bc )
}

scale (){ #resolution
	# erst länge in sek ermitteln
	mkv_laenge "$2"

	
#	if [ "$1" == "720p" ]; then
#		dimension="1280:720"
#		bitrate="3600"
#	else
#		dimension="720:480"
#		bitrate="1500"
#	fi	

	case $1 in	
		720p)
			dimension="1280:720"
			bitrate="4500";;
		480p)
			dimension="720:480"
			bitrate="1800";;
		1080p)
			dimension="1920:1280"
			bitrate="10240";;

	esac
}
cur_laenge () { #output
	path=`pwd`
	in=`realpath $1.264`
	in="$pwd$1.264"
	akt_laenge=`ls -s $1 | cut -d" " -f 1`
}
prozent_bar () { # laenge, akt_laenge
	sh /home/oswaldo/prog/bash/bdrip/prozent.sh $1  $2
}
process (){ #name der Prozess
	pro=$(ps cax | grep "$1")
	if [ -z "$pro" ]; then
		run=0
	else
		run=1
	fi
}

#
#-----------------------------------------
#
balken () { #process, mkv_size, zieldatei

	#echo $mkv_size
	sleep 2 #wait for process to create 
	#jetzt anfangn zu zählen
	elapsed=2
	cur_laenge "$3"
	old_laenge=$akt_laenge
	process "$1"
#	echo $run
	while (( $run == 1 ))
	do
		bitrate_c $old_laenge $akt_laenge
		/home/oswaldo/prog/bash/bdrip/prozent-1.1.sh $2 $akt_laenge $elapsed $bit
		process "$1"
		old_laenge=$akt_laenge
		sleep  1
		cur_laenge  "$3"
		#zeit um 1 erhöhn
		(( elapsed++ ))
	done
}
cleanup () {
	echo "cleaning up"
	echo "##########################################"
	`rm *.264`
	`rm *.aac`
	`rm *.sup`
}
#Video kodieren und verkleinern
video () { #inputname, outputname, bitrate, dimension,mkv, pass

# neu mit preset, tune 
	`(mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:preset=$preset:tune=film -o $2.264  > /dev/null 2>&1 &)`
	
	balken "mencoder" $mkv_size "$2.264"
	sleep 5
	
	echo "done riping video"
	echo "##########################################"
	echo "making $2.mkv"
	$5
	echo "##########################################"
	pro=$(ls *.mkv)
	if [ -z "$pro" ]; then
		echo "there was an error. All files remained"
	else
		cleanup
	fi
}
#
#---------------------------------------------------------------------------------------
#

if [ ! $# == 4 ]; then
	echo "Usage: $0 [outputname] [inputname] [resolution] [preset 1(fastest)- 8(slowest)]"
else
	scale "$3"
	preset $4
	echo "Converting to $3 ($dimension) -> $preset"
	echo "Saving to: $1.mkv from: $2"	
	mkv_laenge $2
	fps $2
	dur=$(echo "scale=0; $laufzeit * 1" | bc )
	round $dur
	duration=$rund
	convert_time $duration
	#echo $dur
	echo "Dauer: "$laufzeit"s ("$hour":"$minuten":"$sek")"
	#echo "Dauer: "$laufzeit"s "
	echo "FPS: $fps"
	echo "====================="
	mkv_size=$(echo "$laufzeit * $bitrate / 8 * 97 / 100" | bc )
	mb=$(echo "scale=2; $mkv_size / 1024" | bc )
	gb=$(echo "scale=2; $mkv_size / 1048576" | bc )
	echo "Size: $mkv_size kb ($mb mb -> $gb gb)"
	echo "====================="
#get # audio streams
	echo "AUDIO: "
	read audiostreams
	tracks=$audiostreams
	for ((i=0; i < audiostreams; i++))
	do
		atracks=$(( $i + 1 ))
		#echo "Enter ${i} language:"
		echo "Enter $atracks language:"
		read lang
 		audio[$i]=$lang
		echo "Enter aid for ${audio[$i]}:"
		read alang
		aid[$i]=$alang
		#für tracksorder in mmkv
		#ab # von audio kommmmt subs -> s. nächste schleife
		#audio tracks enden in 0, tracks ändern aber
		tracks_order[$i]=$atracks:0

	done
	echo "===================="
	#-----------------------------------------------
	#subtitles
	#-----------------------------------------------
	echo "Subtitles:"
	read subs

	for ((i=0; i < subs; i++))
	do
		#echo "Enter ${i} language in mkv:"
		echo "Enter $stracks language in mkv:"
		read lang
		sublang[$i]=$lang
		echo "Enter track id for ${sublang[$i]}:"
		read slang
		sid[$i]=$slang
		#s.o. 
		#fängt ab audiospuren an
		#untertiteln daggen fangen mit 0 an und enden in steigenden Nummern

		tracks_order[$tracks]=$tracks:0
		(( tracks += 1 ))
	done
	echo "===================="
	echo "External Subtitles:"
	read srts

	for ((i=0; i < srts; i++))
	do
		#variable number
		stracks=$(( $i + 1 ))
		#echo "Enter ${i} language in mkv:"
		echo "Enter $stracks desired language in mkv:"
		read lang
		srt[$i]=$lang
		echo "Enter filename for ${srt[$i]}:"
		read eslang
		ext[$i]=$eslang
		#s.o.
		#subtitles end with variable nmber, but beginn with0 e.g 0:1, 0:2
		#fängt ab audiospuren an
		tracks_order[$tracks]=$tracks:0
		(( tracks += 1 ))
	done
	i=0
	for AUDIO in "${audio[@]}"
	do
		audio_mkv="$audio_mkv-a 0 -D -S -T --language 0:$AUDIO $AUDIO.aac "		
	done

	echo "===================="

	for sub in "${sublang[@]}"
	do
		sub_mkv="$sub_mkv-s 0 -A -T --language 0:$sub $sub.sup "		
	done
	echo "===================="

	for (( i=0; i<srts; i++ ))
	do
		srt_mkv="$srt_mkv-s 0 -A -T --language 0:${srt[$i]} "${ext[$i]}" "
	done
#	for sub in "${srt[@]}"
#	do
#		srt_mkv="$sub_mkv-s 0 --language 0:$sub $sub.sup "		
#	done
#------------------------------------------------------------
	#track order
	#tid=1
	#for type_t in "${tracks_order[@]}"
	#for ((i=0; i < $tracks; i++ ))
	for type_t in "${tracks_order[@]}"
	do
		to=$to,$type_t
	done
	
#	mp4="MP4Box -fps 25 -add $1.264 $audio_mp4 $sub_mp4 $1.mp4"
	#mkv="mkvmerge -o $1.mkv -d 0 --default-duration 0:24000/1001fps $1.264 $audio_mkv $sub_mkv --track-order 0:0$to"
	mkv="mkvmerge -o $1.mkv -d 0 --default-duration 0:"$fps"fps $1.264 $audio_mkv $sub_mkv $srt_mkv "
	#mkv="mkvmerge -o $1.mkv -d 0 --default-duration 0:"$fps"fps $1.264 $audio_mkv $sub_mkv $srt_mkv --track-order 0:0$to >/dev/null 2>&1 &"
	echo $mkv
	echo "===================="
	#audioo
	#-----------------------------------------------
	echo "Processing audio:"
	#for AUDIO in "${aid[@]}"
	for ((i=0; i < audiostreams; i++))	
	do
	#	size_wav $2 $duration
	#	echo "Extracting ${audio[$i]}.wav"
	#mb=$(echo "scale=2; $sizea / 1024" | bc )
	#gb=$(echo "scale=2; $sizea / 1048576" | bc )
	#echo "Size: $sizea kb ($mb mb -> $gb gb)"
	#	`(mplayer $2  -aid ${aid[$i]} -vo null -vc null -ao pcm:fast:file=${audio[$i]}.wav </dev/null >/dev/null 2>&1 &)`
	#	balken "mplayer" $sizea "${audio[$i]}.wav"
	#	echo "["
	#	echo ">  ${audio[$i]}.wav to m4a"
	#	`faac -w -b 150 ${audio[$i]}.wav 2>/dev/null`
		echo ">  extracting ${audio[$i]}.dts"
		mkvextract tracks $2 ${aid[$i]}:${audio[$i]}.dts
		echo ">  ${audio[$i]}.dts to .aac"
		ffmpeg -i ${audio[$i]}.dts  -acodec libfaac ${audio[$i]}.aac >  /dev/null 2>&1
		echo "deleting ${audio[$i]}.dts"
		rm ${audio[$i]}.dts
		echo "------------------------------------"
	done
	echo "===================="
	echo "Processing Subtitles:"
	for ((s=0; s < subs; s++))
	do
		echo "Extracting ${sublang[$s]} with track id ${sid[$s]}"
		`mkvextract tracks $2 ${sid[$s]}:${sublang[$s]}.sup`
		echo ">  ${sublang[$s]}.sup"
		
	done
	echo "############################################"
	echo "############################################"
	echo "Processing video:"
	echo "This may take a while..."
	video "$2" "$1" "$bitrate" "$dimension" "$mkv" "$5"
fi

