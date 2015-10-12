#!/bin/bash
source "$BINDIR/"validarCampos.sh
source "$BINDIR/"validarLLamada.sh
source "$BINDIR/"verificarUmbrales.sh

export LLAMADA_VALIDA="llamada valida"
export LLAMADA_INVALIDA="llamada invalida"
main () {
ls  "$ACEPDIR" > archivosllamadas.txt
while read nombreArchivo || [ -n "$nombreArchivo" ]
do	
	validarArchivoLlamada "$nombreArchivo"
	esArchivoValido=$?
	local RUTA="$ACEPDIR/"$nombreArchivo
	if [ $esArchivoValido  -eq 0 ] 
	then
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Se rechaza el archivo por estar DUPLICADO." "INFO"
		"$BINDIR"/MOVERA.sh "$RUTA" "$RECHDIR"
	else 
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Archivo a procesar: $nombreArchivo" "INFO"
		local idCentral=$(echo $nombreArchivo | awk -F'_' '{ print $1 }')
		aniomesdia=$(echo $nombreArchivo | awk -F'_' '{ print $2 }')
		local linea
		let sospechosas=0
		let noSospechosas=0
		let conUmbral=0
		let sinUmbral=0
		let registrosRechazados=0
		let cantidadLLamadas=0
		while read linea || [ -n "$linea" ]
		do
			cantidadLLamadas=`expr $cantidadLLamadas + 1`
			validarCampos "$linea" registroErrores 
			llamadaEsValida=$(echo "$registroErrores" | awk -F ';' '{ print $1 }')
			case "$llamadaEsValida" in
			"llamada valida")
				clasificarLLamada "$linea" tipoLLamada
				verificarUmbralYgrabarLLamadaSospechosa "$linea" "$tipoLLamada" "$idCentral" "$aniomesdia"
				local res="$?"
				if [ "$res" -eq 0 ]
					then
					sinUmbral=`expr $sinUmbral + 1`
				else
					conUmbral=`expr $conUmbral + 1` 
					if [ "$res" -eq 2 ]
						then
						sospechosas=`expr $sospechosas + 1`
					fi
				fi
			;;
			"llamada invalida")
				grabarLLamadaRechazada "$linea" "$registroErrores" "$idCentral"
				registrosRechazados=`expr $registrosRechazados + 1`
			;;
			"$CANTIDAD_CAMPOS_INCORRECTOS")
				registrosRechazados=`expr $registrosRechazados + 1`
				grabarLLamadaRechazada "$linea" "$registroErrores" "$idCentral"
			;;
			esac
		done < "$RUTA"
		noSospechosas=`expr $cantidadLLamadas - $sospechosas` 
		
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
	motivosDeRechazo=$( echo "$registroErrores" | sed  's/valido//g')
	motivosDeRechazo=$(echo "$motivosDeRechazo" | sed 's/llamada invalida//')
	motivosDeRechazo=$(echo "$motivosDeRechazo" | sed 's/;//g')
	registroRechazo="$nombreArchivo;$motivosDeRechazo;$idAgente;$fechaYHora;\
	$tiempoConversacion;$numeroAreaA;$numeroLineaA;$numeroPais;$numeroAreaB\
	;$numeroLineaB"
	echo "$registroRechazo" >> "$RECHDIR/llamadas/$idCentral.rech"
}


main