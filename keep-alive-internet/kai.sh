#/bin/bash
packets="1"
#x=$(links -lookup www.google.de)
#echo $x
run=1
vzeit=0
reconnects=0
############################################################################
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
################################################################################
while (( $run == 1 )); do
	x=$(ping  www.google.de -c 1 2> /dev/null | grep packets | cut -d" " -f 1) 
	if ! ((  $x  )); then
		#systemctl restart wpa_supplicant@wlp3s0
		wpa_cli reassociate > /dev/null 2>&1
		convert_time $vzeit
		(( "reconnects++" ))
		echo $reconnects". connection: "$hour:$minuten:$sek"                "
		echo "-------------------------"
		vzeit=0
		sleep 10
	else
		convert_time $vzeit
		echo -en "elapsed time: $hour:$minuten:$sek  \r"
		sleep 1
		(( "vzeit++" ))
	fi
done
