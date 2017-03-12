#!/bin/bash	
#program to reduce 1080p to given resolution (720p or 480p)

#---------------------------------------------------------------------------------------
scale (){ #resolution
	if [ "$1" == "720p" ]; then
		dimension="1280:720"
		bitrate=3500
	else
		dimension="720:480"
		bitrate=1400
	fi	
}
sub () { #input
	# number subs in medium
	anzahl=`mkvinfo $1 | grep subtitle | wc -l`
	#get the first line number
	erstenummer=`mkvinfo $1 | nl | grep subtitle > line`
	#cycle though subs



}
video () { #inputname, outputname, bitrate, dimension
	zeit=0
	done=0 #0-> nicht fertig, 1-> fertig
     #pass 1
	echo "Pass1..."
	
		`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=auto:pass=1 -o /dev/null &`


        #pass 2
		echo "Pass2..."
		`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,scale=$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:threads=auto:pass=2 -o $2.264 &` 
	`rm div*`
	echo "done riping video"
}

prozent () { #input, bitrate
	#duration
	dauer=`mkvinfo $1 | grep Dauer`
}

#---------------------------------------------------------------------------------------

if [ ! $# == 3 ]; then
	echo "Usage: $0 [outputname] [inputname] [bitrate] [dimensions]"
else
	echo "====================="
	#get # audio streams
	echo "AUDIO: "
	read audiostreams
	for ((i=0; i < audiostreams; i++))
	do
		echo "Enter ${i} language:"
		read lang
 		audio[$i]=$lang
		echo "Enter aid for ${audio[$i]}:"
		read alang
		aid[$i]=$alang

	done
	echo "===================="
	#-----------------------------------------------
	#subtitles
	#-----------------------------------------------
	echo "Subtitles:"
	read subs
	for ((i=0; i < subs; i++))
	do
		echo "Enter ${i} language:"
		read lang
		sublang[$i]=$lang
		echo "Enter sid for ${sublang[$i]}:"
		read slang
		sid[$i]=$slang
	done
	echo "===================="
	#----------------------------------------------------
	#mp4
	#----------------------------------------------------
	mp4="-add $2.264 -fps 25 "
	i=0
#	audio_mp4=" "
#	subs_mp4=""
	for AUDIO in "${audio[@]}"
	do
		audio_mp4="$audio_mp4-add $AUDIO.m4a:lang=$AUDIO "		
#		let "i=$i + 1"
	done

	echo "===================="

	for sub in "${sublang[@]}"
	do
		sub_mp4="$sub_mp4-add $sub.idx "		
	done
	
	mp4="MP4Box -fps 25 -add $1.264 $audio_mp4 $sub_mp4 $1.mp4"
	echo $mp4
	echo "===================="
	#audioo
	#-----------------------------------------------
	echo "Processing audio:"
	#for AUDIO in "${aid[@]}"
	for ((i=0; i < audiostreams; i++))	
	do
		echo "Extracting ${audio[$i]}.wav"
		#nur mit aid
#		`mplayer $2  -aid $AUDIO -vo null -vc null -ao pcm:fast:file=$AUDIO.wav 2>&1 > /dev/null`
		`mplayer $2  -aid ${aid[$i]} -vo null -vc null -ao pcm:fast:file=${audio[$i]}.wav 2>&1 > /dev/null`
		#`mplayer $2  -alang $AUDIO -vo null -vc null -ao pcm:fast:file=$AUDIO.wav 2>&1 > /dev/null`
		echo "Converting wav to m4a"
		`faac -w -b 150 ${audio[$i]}.wav 2>&1 > /dev/null`
		`rm ${audio[$i]}.wav`
	done
	echo "===================="
	echo "Processing Subtitles:"
	for ((s=0; s < subs; s++))
	do
		echo "Extracting ${sublang[$s]} with sid ${sid[$s]}"
		`mencoder $2 -sid ${sid[$s]} -vobsubout ${sublang[$s]} -oac copy -ovc copy -o /dev/null 2>&1 > /dev/null`
	done
	echo "===================="
	echo "Processing video:"
	echo "Converting to $4 -> $dimension"
	echo "Saving to: $1.mp4 from: $2"
	echo "This may take a while..."
	scale "$4"
	video "$2" "$1" "$bitrate" "$dimension"
	`rm =`
fi

