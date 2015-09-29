#!/bin/bash
source validarCampos.sh
# mover estas variables a un archivo
# de configuracion

DIRLLAMADAS="ACEPDIR/"
DIRCDA="MAEDIR/CdA.mae"
DIRCDP="MAEDIR/CdP.mae"
AGENTES="MAEDIR/agentes.mae"
DIRLLAMADAS="ACEPDIR/"

main () {

ls  "$DIRLLAMADAS" | grep .csv > archivosllamadas.txt

while read nombreArchivo 
do	
	validarArchivoLlamada "$nombreArchivo"
	esArchivoValido=$?
	if [ $esArchivoValido  -eq 0 ] 
	then
		echo "Se rechaza el archivo por estar DUPLICADO."
		continue
	fi 

	local RUTA=$DIRLLAMADAS$nombreArchivo
	local linea
	while read linea
	do
		echo "$linea"
	validarCampos "$linea" registroErrores
	echo "$registroErrores" | awk -F ';' '{ print $1 }'
	echo "$linea" | awk -F ';' '{ print $7 }'
	done < "$RUTA"
done < archivosllamadas.txt
}

main