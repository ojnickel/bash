#! /bin/bash
# ganze_groesse, akt_groesse

#nur wenn 2 Argumente
if [ ! $# == 2 ]; then
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
############################################################################


		bar_f $akt_prozent
		bar_e $akt_prozent

		#'\r' mit -en löscht die Zeile
		echo -en "$anfang_bar$full_bar$empty_bar$ende_bar $akt_prozent%\r"
fi
