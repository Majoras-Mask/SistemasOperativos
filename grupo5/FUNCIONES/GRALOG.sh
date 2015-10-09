#!/bin/bash
#LOGDIR="logdir"
#LOGEXT="txt"
#LOGSIZE=5000
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
	if [ "$filesize" -gt "$LOGSIZE" ];then
		echo $(tail --lines=50 "$file") > "$file"
		echo "El Log ha superado su tamaño maximo" >> "$file"
	fi
	echo "$(date)---$(id -u -n)---$command---$type---$message" >> "$file"
else
	echo "$(date)---$(id -u -n)---$command---$type---$message" > "$file"
fi
