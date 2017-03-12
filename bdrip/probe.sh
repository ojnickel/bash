#! /bin/bash
	pro=$(ls *.mkv)
	if [ -z "$pro" ]; then
		echo "vacio"
	else
		echo "1"
	fi
anzahl_a=$(mplayer2 $1 -nosound -vo null -frames 1 | grep alang | wc -l)
echo $anzahl_a
for ((i=1; i  <= anzahl_a; i++ ))
do
	pa="$i"p
	"mplayer2 $1 -nosound -vo null -frames 1 2&>1 ./log"
	a=$(cat log | grep alang | sed -n $pa)
	echo "$i. $a" 
done
for (( i=1; i<=3800; i++ ))
do
	./prozent.sh "3800" "$i" "$i"
	sleep 1
done
echo $list
