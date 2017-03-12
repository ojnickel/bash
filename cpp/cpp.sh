#! /bin/bash
process (){ #name der Prozess
	pro=$(ps cax | grep "$1")
	if [ -z "$pro" ]; then
		run=0
	else
		run=1
	fi
}
if [ ! "$#" == 2 ];then
	echo "Usage: $0 [original size] [dest size]"
else
	#original=$(stat -c %s $1)
	original=$(ls -s $1 | cut -d " " -f 1)
	dest_size=0
#	(( original /= 1024 ))
	# echo "$1  $original"
	echo $original
	echo $2
	`cp -r "$1" "$2" &`
	run=1
	i=0
	while (( $run == 1 ))
	do
		process "cp"
		/home/oswaldo/prog/bash/bdrip/prozent.sh $original $dest_size $i
		sleep 1
		(( i++ ))
		dest_size=$(stat -c %s $2)
		(( dest_size /= 1024 ))
	done
	echo " "
fi
