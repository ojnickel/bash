#!/bin/bash	
#get crop for givenmovie
crop () { #input, zeit_faktor -> i * 10:00
#zeit_faktor = $2
let "zeit = $2 * 10"
if [ "$zeit" >= 60 ]; then
	let "alt = $zeit - 60"
	echo "crop in 1:$alt:00"	
else
	echo "crop in $zeit:00"
fi
echo "----------------"
LOG=`mplayer -vf cropdetect $1 -ss "$2":00 -frames 3 -vo null -ao null > log 2>&1` 
	#echo $LOG > log
	CROP=`cat log | grep CROP | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 2`
	`rm log`
}
#---------------------------------------------------------------------------------------
video () { #inputname, outputname, bitrate, crop
     #pass 1
`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=auto:pass=1 -o /dev/null 2>&1 > /dev/null`
        #pass 2
`mencoder $1 -nosound -of rawvideo -nosub -vf pullup,softskip,$4,harddup -oac copy -ovc x264 -x264encopts bitrate=$3:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid=normal:weight_b:threads=auto:pass=2 -o $2.264 2>&1 > /dev/null` 
	`rm div*`


	echo "done riping video"
}

#---------------------------------------------------------------------------------------
mp4 () { #video,audio,sub
	echo "================"
	echo -n "Creating mp4... "
	`MP4Box -fps 25 -add $1.264 $2 $3 $1.mp4`
	echo "done"
}
#---------------------------------------------------------------------------------------
copydir () { #dir, mp4, targetlocation, newDir
	echo "================"
	echo "Creating Directory $1"
	count=1
	for lang in "${audio[@]}"
	do
		let "count=$count + 1"
		if [ "$count" == 1 ]; then
			lang="$lang"
		else
			lang="$lang, $lang"
		fi
	done

	echo "$lang"

#	mkdir "$1[$lang]"
#	echo "Moving directory"
#	mv "$2.mp4 $1[$lang]"
#	mv "$1[$lang] $3"
#	echo "Creating Simlink in new"
#	ln -s $4 "$3/$1[$lang]"


}

if [ ! $# == 3 ]; then
	echo "Usage: $0 [outputname] [inputname] [bitrate]"
else
	richtig="n"	
	zeit_faktor=1
	echo "Getting crop"
	while [ "$richtig" == "n" ]
	do
 		crop "$2" "$zeit_faktor"
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
	#tccat -i ../../original/LARRY_CROWN_DVDR_LATINO_LTW/VIDEO_TS/ -T 2,-1 | tcextract -x ps1 -t vob -a 0x21 > subs-1
	#subtitle2vobsub -o ${RIPPATH}vobsubs -i ${RIPPATH}vts_01_0.ifo -a ${SID} 0 -p subs-1
	for ((s=0; s < subs; s++))
	do
		echo "Extracting ${sublang[$s]} with sid ${sid[$s]}"
		`mencoder $2 -sid ${sid[$s]} -vobsubout ${sublang[$s]} -oac copy -ovc copy -o /dev/null 2>&1 > /dev/null`
	done
	echo "===================="
	echo "Processing video:"
	echo "Using $CROP Bitrate: $3"
	echo "Saving to: $1.mp4 from: $2"
	echo "This may take a while..."
	video "$2" "$1" "$3" "$CROP"
	mp4 "$1" "$audio_mp4" "$sub_mp4"
#	copydir "$1" "$1.mp4" "$4" "$5"
fi

