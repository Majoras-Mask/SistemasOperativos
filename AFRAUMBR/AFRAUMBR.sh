#!/bin/bash
source validar_campos.sh
# mover estas variables a un archivo
# de configuracion

DIRLLAMADAS="ACEPDIR/"
DIRCDA="MAEDIR/CdA.mae"
DIRCDP="MAEDIR/CdP.mae"
AGENTES="MAEDIR/agentes.mae"
DIRLLAMADAS="ACEPDIR/"

ls  "$DIRLLAMADAS" | grep .csv > archivosllamadas.txt

while read nombreArchivo 
do	
	validarArchivoLlamada "$nombreArchivo"
	esArchivoValido=$?
	if [ $esArchivoValido  -eq 0 ] 
	then
		echo “Se rechaza el archivo por estar DUPLICADO“.
		continue
	fi 

	RUTA=$DIRLLAMADAS$nombreArchivo
	while read linea
	do
	validarCampos "$linea" registroErrores
	echo "$registroLLamada" | awk -F ':' '{ print $1 }'
	
	done < "$RUTA"
done < archivosllamadas.txt
