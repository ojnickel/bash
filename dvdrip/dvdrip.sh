#!/bin/bash	
#get crop for givenmovie

#functiond
#------------------------------------

#=======================================================
crop () { #dvd-device, title, zeit_faktor -> i * 10:00
#zeit_faktor = $2
let "zeit = $2 * 10"
if [ "$zeit" >= 60 ]; then
	let "alt = $zeit - 60"
	echo "crop in 1:$alt:00"	
else
	echo "crop in $zeit:00"
fi
echo "----------------"
LOG=`mplayer -vf cropdetect -dvd-device $1 dvd://$2 -ss "$3":00 -frames 3 -vo null -ao null > log 2>&1` 
	#echo $LOG > log
	CROP=`cat log | grep CROP | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 2`
	`rm log`
}
#======================================================

#=====================================================
video () { #dvd-device, title, outputname, bitrate, crop
     #pass 1
`mencoder -dvd-device $1 dvd://$2 -nosound -of rawvideo -nosub -vf pullup,softskip,$5,harddup -oac copy -ovc x264 -x264encopts bitrate=$4:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=auto:pass=1 -o /dev/null 2>&1 > /dev/null`
        #pass 2
`mencoder -dvd-device $1 dvd://$2 -nosound -of rawvideo -nosub -vf pullup,softskip,$5,harddup -oac copy -ovc x264 -x264encopts bitrate=$4:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:threads=auto:pass=2 -o $3.264 2>&1 > /dev/null` 
	`rm div*`


	echo "done riping video"
	echo "###########################################"
	echo "cleaning up..."
	`rm *.264 *.m4a *.idx *.sub sub* =`
	echo "###########################################"
}

#======================================================

#======================================================
mp4 () { #video,audio,sub
	echo "==,,=============="
	echo -n "Creating mp4... "
	`MP4Box -fps 25 -add $1.264 $2 $3 $1.mp4`
	echo "done"
}
#=====================================================

cleanup () {
	rm *.idx
	rm *.sub
	rm *.m4a
	rm *.264
	rm div*
	rm *.wav
}
#---------------------------------------------------------


#=========================================================================================
#############Main#########################################################################
#=========================================================================================

if [ ! $# == 5 ]; then
	echo "Usage: $0 [dvd-device] [title] [outputname] [bitrate] [fps]"
else
	richtig="n"	
	zeit_faktor=1
	echo "Getting crop"
	while [ "$richtig" == "n" ]
	do
 		crop "$1" "$2" "$zeit_faktor"
		echo "->" "$CROP" "<-"
		echo "Correct? (y/n)"
		read richtig
		let "zeit_faktor = $zeit_faktor + 1"
	done
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
	mp4="-add $3.264 -fps $5 "
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
		sub_mp4="$sub_mp4-add $sub.idx:lang=$sub "		
	done
	
	mp4="MP4Box -fps $5 -add $3.264 $audio_mp4 $sub_mp4 $3.mp4"
	echo $mp4
	echo "===================="
	#-----------------------------------------------


	#audio
	#-----------------------------------------------
	echo "Processing audio:"
	#for AUDIO in "${aid[@]}"
	for ((i=0; i < audiostreams; i++))	
	do
		echo "Extracting ${audio[$i]}.wav"
		#nur mit aid

		`mplayer -dvd-device $1 dvd://$2 -aid ${aid[$i]} -vo null -vc null -ao pcm:fast:file=${audio[$i]}.wav 2>&1 > /dev/null`

		echo "Converting wav to m4a"
		`faac -w -b 150 ${audio[$i]}.wav 2>&1 > /dev/null`
		`rm ${audio[$i]}.wav`
	done
	echo "===================="
	#--------------------------------------------------


	#subs,
	#--------------------------------------------------
	echo "Processing Subtitles:"
	for ((s=0; s < subs; s++))
	do
		echo "Extracting ${sublang[$s]} with sid ${sid[$s]}"
		`tccat -i $1 -T $2,-1 | tcextract -x ps1 -t vob -a 0x2${sid[$s]} > subs-${sid[$s]}`
		`subtitle2vobsub -o ${sublang[$s]}  -i $1/VIDEO_TS/VTS_$2_0.IFO -p subs-${sid[$s]}`
	done
	echo "===================="
	#---------------------------------------------------


	#video
	#---------------------------------------------------
	echo "Processing video:"
	echo "Using $CROP Bitrate: $3"
	echo "Saving to: $1.mp4 from: $2"
	echo "This may take a while..."
	video "$1" "$2" "$3" "$4" "$CROP"
	mp4 "$3" "$audio_mp4" "$sub_mp4"
	clenup
fi

