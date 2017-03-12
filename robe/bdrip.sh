#!/bin/bash	
	#linie zurücksetzen
	backspaces (){ #anzahl zu "loeschende" zeichen
		for (( x=0; x< $1; x++ )); do
			back="$back\b"
		done
	}
i=0
while [ $i -le 100 ]
do
	sleep 1
	./prozent.sh 100 $i
	if [ $i -lt 10 ];then
		backspaces 105
	else
		backspaces 106
	fi
	let "i += 1"
done
echo -e "\n"
