#!/bin/bash
#LOGDIR="logdir"
#LOGEXT="txt"
#LOGSIZE=5000

if [ "$LOGDIR" == "" ] || [ "$LOGSIZE" == "" ] || [ "$LOGEXT" == "" ];then
	echo "Variables de entorno no inicializadas. Exiting"
	exit 1
fi

if [ ! -d "$LOGDIR" ];then
	mkdir -p "$LOGDIR"
fi

command=$1
message=$2
type=$3
if [ -z "$3" ];then
	type="INFO"
fi
lastchar="${LOGDIR:((${#LOGDIR}-1)):1}"
if [ $lastchar == "/" ];then
	file="$LOGDIR$command.$LOGEXT"
else
	file="$LOGDIR/$command.$LOGEXT"
fi
if [ -f "$file" ];then
	info=$(ls -l "$file")
	count=0
	for word in $info
	do
		let "count++"
		if [ "$count" == 5 ];then
			filesize="$word"
		fi
	done
	filesize=$(du -k "$file" | cut -f1)
	if [ "$filesize" -gt "$LOGSIZE" ];then
		tail --lines=50 "$file" > "/tmp/temporal.txt"
		cat "/tmp/temporal.txt" > "$file"
		echo "$(date +"%d/%m/%y %R")---$USER---GRALOG---INFO---El Log ha superado su tamaño maximo" >> "$file"
	fi
	echo "$(date +"%d/%m/%y %R")---$USER---$command---$type---$message" >> "$file"
else
	echo "$(date +"%d/%m/%y %R")---$USER---$command---$type---$message" > "$file"
fi
