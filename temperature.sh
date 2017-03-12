#! /bin/bash
temp=$( echo /sys/class/thermal/thermal_zone0/temp)
celsius=$( $temp / 1000)
echo $celsius
temperature="printf "%3.1f°C\n" `cat /sys/class/thermal/thermal_zone0/temp | awk -F, '{print $1}'`"
