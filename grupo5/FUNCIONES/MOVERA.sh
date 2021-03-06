#!/bin/bash
if [ ! -f "$BINDIR"/GRALOG.sh ];then
	echo "No se encuentra GRALOG.sh. Exiting."
	exit 1
fi
origin=$1
destiny=$2
command=$3
lastchar="${destiny:((${#destiny}-1)):1}"
if [ $lastchar != "/" ];then
	destiny="$destiny/"
fi
filename=$(basename "$origin")
filedir=$(dirname "$origin")
filedir="$filedir/"
if [ "$filedir" == "$destiny" ];then
	if [ -z "$command" ]; then
		echo "Carpeta origen igual a carpeta destino."
	else
		"$BINDIR"/GRALOG.sh "$command" "Carpeta origen igual a carpeta destino." "WAR"
	fi
elif [ -f "$origin" ] && [ -d "$destiny" ];then
	duplicate=$destiny$filename
	if [ -f "$duplicate" ];then
		if [ ! -d "${destiny}duplicates" ];then
			mkdir "${destiny}duplicates"
		fi
		duplicate=${destiny}duplicates/${filename}
		if [ ! -f "${duplicate}.001" ];then
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
	if [ -z "$command" ];then
		if [ ! -f "$origin" ];then
			echo "El archivo de origen $origin no existe"
		fi
		if [ ! -d "$destiny" ];then
			echo "El directorio de destino $destiny no existe"
		fi
	else
		if [ ! -f "$origin" ];then
			"$BINDIR"/GRALOG.sh "$command" "El archivo de origen $origin no existe" "ERR"
		fi
		if [ ! -d "$destiny" ];then
			"$BINDIR"/GRALOG.sh "$command" "El directorio de destino $destiny no existe" "ERR"
		fi
	fi
	
fi
