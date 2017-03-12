#! /bin/bash
# ganze_groesse, akt_groesse

#nur wenn 2 Argumente
if [ ! $# == 3 ]; then
	echo "Usage: $0 [whole size] [current size]"
else
	anfang_bar="["
	ende_bar="]"
	
	#damit nicht komma stellen vorkommen
	declare -i akt_prozent 	

	akt_prozent=$(( $2*100/$1 ))
	#pass mit den counters von for auf
	#fill up bar with =
	bar_f (){ #prozent
		for (( j=0; j< $1; j++ )); do
			full_bar=$full_bar=
		done
	}
	#leere stellen danach
	bar_e (){ #aktprozent
		zeichen=$(( 100 - $1))
		for (( z=0; z< $zeichen; z++ )); do
			empty_bar=$empty_bar"-"
		done
	}
	#bar "loeschen" -> sonst fullbar u empty_werden immer dia alte werte behaten
	reset (){ #fullbar, emptybar
		full_bar=""
		empty_bar=""
	}
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
round () { #whole, current, elapsed
	#berechnet ganze Zeit
	a=$(echo "scale=3; $1 / $2" | bc )
	b=$(echo "scale=3; $a * $3" | bc )
	#Zeit zum fertig werden
	c=$(echo "scale=3; $b - $3" | bc )

	#damit nachkomma nicht verloren geht
	z=$(echo "scale=3; $c * 1000" | bc )
	#zahl_zu_runden=$(( $c * 10.0 ))
	ohne_komas=${z/.*}
	#nachkomma-Zahl
	nach_komma=$(( $ohne_komas % 10 ))

	if [ $nach_komma == 0 ]; then
		eta=$(( $ohne_komas/1000 ))
	else
		eta=$(( $ohne_komas - $nach_komma ))
		#wieder normal
		(( eta /= 1000 ))
		#zur nachsten nummer
		(( eta++ ))
	fi
}
#############################################################################
		bar_f $akt_prozent
		bar_e $akt_prozent
		round $1 $2 $3
		#erst vrgangeen zeit
		convert_time $3
		std=$hour
		minu=$minuten
		seco=$sek
		#dann übrige zeit
		convert_time $eta
		mb=$(echo "scale=2; $2 / 1024" | bc )
		gb=$(echo "scale=2; $mb / 1024" | bc )
		#'\r' mit -en löscht die Zeile
		echo -en "$anfang_bar$full_bar$empty_bar$ende_bar $akt_prozent% $2 kb ($mb mb or $gb gb) ETA: "$eta"s ("$hour":"$minuten":$sek) Elapsed: "$3"s ($std:$minu:$seco)            \r"
fi
