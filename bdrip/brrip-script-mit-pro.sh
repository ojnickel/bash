#!/bin/bash	
#program to reduce 1080p to given resolution (720p or 480p)
###############################################################################
# für prozent

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
	sizea=$(( $1 * $2 * $(( $3 / 8 )) * $4 ))
}



#größe setzen
mkv_laenge () { #film
#	laufzeit=`mkvinfo $1 | grep  Dauer | cut -d " "  -f 4 | cut -d "s" -f 1`
	laufzeit=$( mkvinfo $1 | grep  Dauer | cut -d " "  -f 4 | cut -d "s" -f 1 | bc )
}

scale (){ #resolution
	# erst länge in sek ermitteln
	mkv_laenge "$2"

	if [ "$1" == "720p" ]; then
		dimension="1280:720"
		bitrate="3600"
	else
		dimension="720:480"
		bitrate="1500"
	fi	
}
cur_laenge () { #output
	path=`pwd`
	in=`realpath $1.264`
	#in="$pwd$1.264"
	akt_laenge=`ls -s $in | cut -d" " -f 1`
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

#Video kodieren und verkleinern
video () { #inputname, outputname, bitrate, dimension,mkv, pass

     #pass 1
#`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=auto:pass=1 -o $2.264 2>&1 > /dev/null`
        #pass 2
#`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:threads=auto:pass=2 -o $2.264 2>&1 > /dev/null` 
# neu mit preset, tune und #pass
if [ "$6" == "2" ]; then
	# 1. pass
	`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:preset=$preset:tune=film:turbo=1:pass=1 -o $2.264 2>&1 > /dev/null`
	# 2. pass
	`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:preset=$preset:tune=film:pass=2 -o $2.264 2>&1 > /dev/null` 
	`rm div*`
else
	`(mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:preset=$preset:tune=film -o $2.264 </dev/null >/dev/null 2>&1 &)`
	
	#echo $mkv_size
sleep 1 #wait for mencoder to create .264
	#jetzt anfangn zu zählen
	elapsed=0
	cur_laenge "$2"
	process "mencoder"
#	echo $run
	while (( $run == 1 ))
	do
		/home/oswaldo/prog/bash/bdrip/prozent.sh $mkv_size $akt_laenge $elapsed
		cur_laenge  "$2"
		process "mencoder"
		sleep  1
		#zeit um 1 erhöhn
		(( elapsed++ ))
	done
	sleep 10
fi
	echo "done riping video"
	echo "##########################################"
	echo "making $2.mkv"
	$5
	echo "##########################################"
	echo "cleaning up"
	echo "##########################################"
	`rm *.264`
	`rm *.wav`
	`rm *.m4a`
	`rm *.sup`
}
#
#---------------------------------------------------------------------------------------
#

if [ ! $# == 5 ]; then
	echo "Usage: $0 [outputname] [inputname] [dimensions] [preset 1(fastest)- 8(slowest)] [pass]"
else
	scale "$3"
	preset $4
	echo "Converting to $3 ($dimension) -> $preset"
	echo "Saving to: $1.mkv from: $2"	
	mkv_laenge $2
	echo "Dauer: $laufzeit s"
	fps $2
	echo "FPS: $fps"
	echo "====================="
#	echo "Enter Duration:"
#	read duration
	mkv_size=$(echo "$laufzeit * $bitrate / 8" | bc )
	mb=$(echo "scale=2; $mkv_size / 1024" | bc )
	gb=$(echo "scale=2; $mkv_size / 1048576" | bc )
	#mkv_size=$(( $duration * $bitrate / 8  )) #kbytes
	echo "Size: $mkv_size kb ($mb mb -> $gb gb)"
	cur_laenge "$1"
	echo $path
	echo $in
	echo "====================="
#get # audio streams
	echo "AUDIO: "
	read audiostreams
	tracks=$audiostreams
	for ((i=0; i < audiostreams; i++))
	do
		echo "Enter ${i} language:"
		read lang
 		audio[$i]=$lang
		echo "Enter aid for ${audio[$i]}:"
		read alang
		aid[$i]=$alang
		#für tracksorder in mmkv
		#ab # von audio kommmmt subs -> s. nächste schleife
		tracks_order[$i]=1

	done
	echo "===================="
	#-----------------------------------------------
	#subtitles
	#-----------------------------------------------
	echo "Subtitles:"
	read subs

	for ((i=0; i < subs; i++))
	do
		echo "Enter ${i} language in mkv:"
		read lang
		sublang[$i]=$lang
		echo "Enter track id for ${sublang[$i]}:"
		read slang
		sid[$i]=$slang
		#s.o. 
		#fängt ab audiospuren an
		tracks_order[$tracks]=0
		(( tracks += 1 ))
	done
	echo "===================="
	#-------iiiiiiiiiiiiiiii---------------------------------------------
	#mp4
	#----------------------------------------------------
#	mkv="-add $2.264 -fps 25 "
	i=0
#	audio_mkv=" "
#	subs_mkv=""
	for AUDIO in "${audio[@]}"
	do
		audio_mkv="$audio_mkv-a 1 --language 1:$AUDIO $AUDIO.m4a "		
	done

	echo "===================="

	for sub in "${sublang[@]}"
	do
		sub_mkv="$sub_mkv-s 0 --language 0:$sub $sub.sup "		
	done
#------------------------------------------------------------
	#track order
	tid=1
	for type_t in "${tracks_order[@]}"
	do
		to=$to,$tid:$type_t
		let tid++
	done
	
#	mp4="MP4Box -fps 25 -add $1.264 $audio_mp4 $sub_mp4 $1.mp4"
	#mkv="mkvmerge -o $1.mkv -d 0 --default-duration 0:24000/1001fps $1.264 $audio_mkv $sub_mkv --track-order 0:0$to"
	mkv="mkvmerge -o $1.mkv -d 0 --default-duration 0:"$fps"fps $1.264 $audio_mkv $sub_mkv --track-order 0:0$to"
	echo $mkv
	echo "===================="
	#audioo
	#-----------------------------------------------
	echo "Processing audio:"
	#for AUDIO in "${aid[@]}"
	for ((i=0; i < audiostreams; i++))	
	do
		echo "Extracting ${audio[$i]}.wav"
		`mplayer $2  -aid ${aid[$i]} -vo null -vc null -ao pcm:fast:file=${audio[$i]}.wav 2>&1 > /dev/null`
		echo ">  ${audio[$i]}.wav to m4a"
		`faac -w -b 150 ${audio[$i]}.wav 2>/dev/null`
	done
	echo "===================="
	echo "Processing Subtitles:"
	for ((s=0; s < subs; s++))
	do
		echo "Extracting ${sublang[$s]} with track id ${sid[$s]}"
		`mkvextract tracks $2 ${sid[$s]}:${sublang[$s]}.sup`
		echo ">  ${ublang[$i]}.aac"
		
	done
	echo "############################################"
	echo "############################################"
	echo "Processing video:"
	echo "This may take a while..."
	video "$2" "$1" "$bitrate" "$dimension" "$mkv" "$5"
fi

