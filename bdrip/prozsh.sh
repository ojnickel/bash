#! /bin/zsh
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
		#mb=$(echo "scale=2; $2 / 1024" | bc )
		mb=$(( $2 / 1024 ))
		gb=$(echo "scale=2; $2 / 1024 / 1024" | bc )
		#'\r' mit -en löscht die Zeile
		#echo -en "$anfang_bar$full_bar$empty_bar$ende_bar $akt_prozent% $2 kb ($mb mb or $gb gb) ETA: $eta s Elapsed time: $3 s\r"
		echo -en "$anfang_bar$full_bar$empty_bar$ende_bar $akt_prozent% $2 kb ($mb mb or $gb gb) Elapsed time: $3 s\r"
fi
