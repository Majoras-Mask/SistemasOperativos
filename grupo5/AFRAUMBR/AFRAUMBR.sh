#!/bin/bash
source "$BINDIR/"validarCampos.sh
source "$BINDIR/"validarLLamada.sh
source "$BINDIR/"verificarUmbrales.sh

export LLAMADA_VALIDA="llamada valida"
export LLAMADA_INVALIDA="llamada invalida"
main () {
echo "inicia afraumbr"
ls  "$ACEPDIR" > archivosllamadas.txt
echo "acepdir = $ACEPDIR"
echo "despues del ls"
while read nombreArchivo || [ -n "$nombreArchivo" ]
do	
	echo "en el while"
	validarArchivoLlamada "$nombreArchivo"
	esArchivoValido=$?
	if [ $esArchivoValido  -eq 0 ] 
	then
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Se rechaza el archivo por estar DUPLICADO." "INFO"
		"$BINDIR"/MOVERA.sh "$nombreArchivo" "$RECHDIR"
	else 
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Archivo a procesar: $nombreArchivo" "INFO"
		local RUTA="$ACEPDIR/"$nombreArchivo
		local linea
		sospechosas=0
		noSospechosas=0
		conUmbral=0
		sinUmbral=0
		registrosRechazados=0
		cantidadLLamadas
		while read linea
		do
			cantidadLLamadas=`expr cantidadLLamadas + 1`
			#echo "$linea"
			local idCentral=$(echo $linea | awk -F'_' '{ print $1 }')
			#echo "$idCentral"
			local aniomesdia=$(echo $linea | awk -F'_' '{ print $2 }')
			#echo "$aniomesdia"
			validarCampos "$linea" registroErrores 
			llamadaEsValida=$(echo "$registroErrores" | awk -F ';' '{ print $1 }')
			case "$llamadaEsValida" in
			"llamada valida")
				echo "$llamadaEsValida"
				echo "llamadaEsValida"
				clasificarLLamada "$linea" tipoLLamada
				verificarUmbralYgrabarLLamadaSospechosa "$linea" "$tipoLLamada" "$idCentral" "$aniomesdia" conUmbral sinUmbral sospechosas
				"$BINDIR"/MOVERA.sh "$nombreArchivo" "$PROCDIR/proc/" "AFRAUMBR"
			;;
			"llamada invalida")
				echo "llamada invalida $cont1 regis = $registroErrores"
				grabarLLamadaRechazada "$linea" "$registroErrores" "$idCentral"
				registrosRechazados=`expr $registrosRechazados + 1`

				#
			;;
			"$CANTIDAD_CAMPOS_INCORRECTOS")
				#MoverA "$nombreArchivo" "$DIR_RECHAZADAS"
				registrosRechazados=`expr $registrosRechazados + 1`
			;;
			esac
		done < "$RUTA"
		noSospechosas=`expr $cantidadLLamadas - sospechosas` 
		
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Cantidad de llamadas = \
		$cantidadLLamadas: Rechazadas $registrosRechazados, \
		Con umbral = $conUmbral, Sin umbral $sinUmbral"
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Cantidad de llamadas\
		 sospechosas $sospechosas, no sospechosas $noSospechosas" "INFO"
		 "$BINDIR"/MOVERA.sh "$RUTA" "$PROCDIR/proc/" "AFRAUMBR" 
	fi
done < archivosllamadas.txt
}

grabarLLamadaRechazada() {
	local linea="$1"
	local registroErrores="$2"
	local idCentral="$3"
	local idAgente
	local fechaYHora
	local numeroAreaA
	local numeroLineaA
	local numeroPaisB
	local numeroAreaB
	local numeroLineaB
	local tiempoConversacion
	parsearLLamada "$linea" idAgente fechaYHora numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
	motivosDeRechazo=$( echo "$registroErrores" | sed -e 's/valido;//' -e 's/;valido;//' -e 's/;valido$//')
	motivosDeRechazo=$(echo $motivosDeRechazo | sed 's/;/,/')
	registroRechazo="$nombreArchivo;$motivosDeRechazo;$idAgente;$fechaYHora;\
	$tiempoConversacion;$numeroAreaA;$numeroLineaA;$numeroPais;BnumeroAreaB\
	;$numeroLineaB"
	echo "$registroRechazo" >> "$PROCDIR/proc/$idCentral.rech"
}


main