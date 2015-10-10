#!/bin/bash
source validarCampos.sh
source validarLLamada.sh
source verificarUmbrales.sh

export LLAMADA_VALIDA="llamada valida"
export LLAMADA_INVALIDA="llamada invalida"
main () {

ls  "$ACEPDIR" | grep .csv > archivosllamadas.txt

while read nombreArchivo 
do	
	validarArchivoLlamada "$nombreArchivo"
	esArchivoValido=$?
	if [ $esArchivoValido  -eq 0 ] 
	then
		echo "Se rechaza el archivo por estar DUPLICADO."
		$BINDIR"/"MOVERA "$nombreArchivo" "$RECHDIR"
	fi 

	local RUTA="$ACEPDIR/"$nombreArchivo
	local linea
	local cont1=0
	while read linea
	do
	let cont1=cont1+1
	#echo "$linea"
	local idCentral=$(echo $linea | awk -F'_' '{ print $1 }')
	#echo "$idCentral"
	local aniomes=$(echo $linea | awk -F'_' '{ print $2 }')
	#echo "$aniomes"
	validarCampos "$linea" registroErrores
	llamadaEsValida=$(echo "$registroErrores" | awk -F ';' '{ print $1 }')
	case "$llamadaEsValida" in
		"llamada valida")
		echo "$llamadaEsValida"
		echo "llamadaEsValida"
		clasificarLLamada "$linea" tipoLLamada
		verificarUmbralYgrabarLLamadaSospechosa "$linea" "$tipoLLamada"
		;;
		"llamada invalida")
		echo "llamada invalida $cont1 regis = $registroErrores"
		;;
		"$CANTIDAD_CAMPOS_INCORRECTOS")
		#MoverA "$nombreArchivo" "$DIR_RECHAZADAS"
		;;
	esac
	done < "$RUTA"
done < archivosllamadas.txt
}
main