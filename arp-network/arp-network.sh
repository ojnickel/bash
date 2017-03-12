#!/bin/bash	
#ping using arp requests the whole network
#network is assumed th have 254 clients
#firewalls of windows and such, blocks icmp query making them invisible for ping

#arp-network [# package that will be send] [network] (only 192.168.0 or so)

if [  $# == 0 ]; then
	echo "Usage: arp-network [interface] [# package that will be send] [network] [star number hosts to scan] [end]"
else
	machine=$4
	#count host up/down
	down=0
	up=0
	while [ "$machine" -lt $5 ]
	do
		arping -I $1 -c $2 $3.$machine > log.txt
		response=`cat log.txt | grep -i received | cut -d ' ' -f 2`
		mac=`cat log.txt | grep -i reply | sed -n 1p | cut -d ' ' -f 5`
		#if [ "$response" == 0 ]; then
		#	echo "$3.$machine is down"
		#	let "down += 1"
		#else
		#	echo "$3.$machine $mac is up"
		#	let "up += 1"
		#fi
		if [ "$response" == 0 ]; then
			#echo "$3.$machine is down"
			let "down += 1"
		else
			netbiosname=`nbtscan $3.$machine | sed -n 5p | cut -d ' ' -f 6`

			echo "$3.$machine $mac ($netbiosname)"
			let "up += 1"
		fi
		let "machine += 1"
	done
	#echo "Hosts down: $down | Hosts up: $up"
	echo "Hosts down: $down | Hosts up: $up"
fi
