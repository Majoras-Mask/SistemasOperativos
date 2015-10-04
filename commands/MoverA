#!/bin/bash
origin=$1
destiny=$2
command=$3
lastchar="${destiny:((${#destiny}-1)):1}"
if [ $lastchar != "/" ];then
	destiny="$destiny/"
fi
filename=$(basename "$origin")
if [ -f "$origin" ] && [ -d "$destiny" ];then
	duplicate=$destiny$filename
	if [ -f "$duplicate" ];then
		if [ ! -d "${destiny}duplicates" ];then
			mkdir "${destiny}duplicates"
		fi
		duplicate=${destiny}duplicates/${filename}
		if [ ! -f ${duplicate}.001 ];then
			mv "$origin" "${duplicate}.001"
		else
			extension=(${duplicate}.*)
			extension=${#extension[@]}
			let "extension++"
			extension=$(printf '%03d' $extension)
			mv "$origin" "${duplicate}.${extension}"
		fi
	else
		mv "$origin" "$duplicate"
	fi
else
	message=""
	if [ -z "$command" ];then
		command="MoverA"
	else
		message="usando MoverA "
	fi
	if [ ! -f "$origin" ];then
		GraLog "$command" "${message}el archivo de origen no existe" "ERROR"
	fi
	if [ ! -d "$destiny" ];then
		GraLog "$command" "${message}el directorio de destino no existe" "ERROR"
	fi
fi
