#!/bin/bash
source validarCampos.sh
source validarLLamada.sh
source verificarUmbrales.sh
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
	local idCentral=$(echo $linea | awk -F'_' '{ print $1 }')
	echo "$idCentral"
	local aniomes=$(echo $linea | awk -F'_' '{ print $2 }')
	echo "$aniomes"
	validarCampos "$linea" registroErrores
	llamadaEsValida=$(echo "$registroErrores" | awk -F ';' '{ print $1 }')
	case "$llamadaEsValida" in
		"$LLAMADA_VALIDA")
		 clasificarLLamada "$linea" tipoLLamada
		 echo "AF tipoLLamada = $tipoLLamada"
		verificarUmbral "$linea" "$tipoLLamada"
		;;
		"$LLAMADA_INVALIDA")
		echo "llamada invalida"
		;;
		"$CANTIDAD_CAMPOS_INCORRECTOS")
		echo "cantidad campos incorrectos"
		;;
	esac
	done < "$RUTA"
done < archivosllamadas.txt
}
main