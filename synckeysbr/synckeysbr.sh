#!/bin/bash
# script for updating KEY.cfg for bluray playback using mplayer2.
# it'll be save in ~/.config/aacs/. Remenber to emmerge aacs.

echo -en "Checking the file in remote host..."
if [ -f "http://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg" ]
then
	echo "si"

else
	echo "no"
fi

