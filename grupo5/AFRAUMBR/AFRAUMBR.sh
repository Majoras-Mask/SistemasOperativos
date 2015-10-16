#!/bin/bash
RETORNO=""
TRUE=0
FALSE=1
DDI="DDI"
DDN="DDN"
LOCAL="LOC"
NOMBRE_ARCHIVO=""
COD_CENTRAL=""
ANIOMESDIA=""
LLAMADAS=0
LLAMADAS_SIN_UMBRAL=0
LLAMADAS_CON_UMBRAL=0
LLAMADAS_SOSPECHOSAS=0
LLAMADAS_NOSOSPECHOSAS=0
LLAMADAS_RECHAZADAS=0

# Temporal
#ACEPDIR="acep"
#RECHDIR="rech"
#PROCDIR="proc"
#MAEDIR="mae"

# Parametros
# $1 : Mensaje a loguear
# $2 : Tipo de mensaje
Loguear(){
    if [ -f "$BINDIR/GRALOG.sh" ];then
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "$1" "$2"
    fi
}

obtenerCantidadDeArchivos(){
	local carpeta="$1"
	RETORNO=$(find "$carpeta" -maxdepth 1 -type f | wc --lines)
	return 0
}

verificarSiArchivoDuplicado(){
	local archivo="$1"
	if [ -f "$PROCDIR/proc/$(basename $archivo)" ]; then
		return "$TRUE"
	else
		return "$FALSE"
	fi
}

verificarSiRegistroTieneFormatoEstablecido(){
	local registro="$1"
	local numeroComas=$(grep -o ";" <<< "$registro" | wc -l)
	if [ $numeroComas -eq 7 ];then
		return "$TRUE"
	else
		return "$FALSE"
	fi
}

verificarSiArchivoTieneFormatoEstablecido(){
	local archivo="$1"
	local lineaArchivo=$(head -n 1 "$archivo")
	verificarSiRegistroTieneFormatoEstablecido "$lineaArchivo"
	return $?
}

verificarSiArchivoOK(){
	local archivo="$1"
	verificarSiArchivoDuplicado "$archivo"
	if [ $? -eq "$TRUE" ];then
		Loguear "Se rechaza el archivo por estar DUPLICADO."
		"$BINDIR"/MOVERA.sh "$archivo" "$RECHDIR" "AFRAUMBR"
		return "$FALSE"
	fi
	
	verificarSiArchivoTieneFormatoEstablecido "$archivo"
	if [ $? -eq "$FALSE" ];then
		Loguear "Se rechaza el archivo porque su estructura no se corresponde con el formato esperado."
		"$BINDIR"/MOVERA.sh "$archivo" "$RECHDIR" "AFRAUMBR"
		return "$FALSE"
	fi	
	
	return "$TRUE"
	
}


#Parametros:
# $1: Codigo de pais B
# $2: Codigo de Area B
# $3: Numero de Linea B
# $4: Codigo de Area A
determinarTipoDeLlamada(){
	if [ ! -z "$1" ]; then
		RETORNO="$DDI"
	elif [ "$2" == "$4" ]; then
		# Codigo de areas iguales
		RETORNO="$LOCAL"
	else
		# Codigo de areas distintos
		RETORNO="$DDN"
	fi
	return 0
}
# $1: Motivo
# $2: Registro
rechazarRegistro(){
	echo "$NOMBRE_ARCHIVO;$1;$2" >> "$RECHDIR/llamadas/$COD_CENTRAL.rech"
}

verificarAgenteValido(){
	local idAgente="$1"
	local cantidad=$(grep -c ".*;.*;$idAgente;.*;.*" "$MAEDIR"/agentes.mae)

	if [ $cantidad -eq 0 ];then
		return "$FALSE"
	else
		return "$TRUE"
	fi
}

verificarAreaValida(){
	local codigoArea="$1"
	local cantidad=$(grep -c ".*;$codigoArea$" "$MAEDIR/CdA.mae")
	
	if [ $cantidad -eq 0 ];then
		return "$FALSE"
	else
		return "$TRUE"
	fi
}

# $1 : A verificar si es numero
verificarSiEsNumero(){
	local n=$( grep -c "^[0-9]\+$" <<< "$1" )
	if [ $n -eq 0 ];then
		return "$FALSE"
	else
		return "$TRUE"
	fi
}

# $1 :Area
# $2: Numero
verificarSiHay10Digitos(){
	local area=$1
	local numero=$2
	local n1=${#area}
	local n2=${#numero}
	local suma=$(expr $n1 + $n2)
	if [ "$suma" -eq 10 ]; then
		return "$TRUE"
	else
		return "$FALSE"
	fi
}

verificarPaisValido(){
	local codigoPais="$1"
	local cantidad=$(grep -c "^$codigoPais;.*" "$MAEDIR/CdP.mae")
	if [ $cantidad -eq 0 ]; then
		return "$FALSE"
	else
		return "$TRUE"
	fi
}

#Parametros:
# $1: Codigo de pais B
# $2: Codigo de Area B
# $3: Numero de Linea B
verificarTipoDeLlamadaValida(){
	if [ "$3" == "" ];then
		return "$FALSE"
	fi
	
	if [ "$1" != "" ] && [ "$2" != "" ];then
		return "$FALSE"
	fi
	
	if [ "$1" == "" ] && [ "$2" == "" ]; then
		return "$FALSE"
	fi
	
	return "$TRUE"
}

verificarRegistro(){
	local registro="$1"
	verificarSiRegistroTieneFormatoEstablecido "$registro"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene el formato esperado." "$registro"
		return "$FALSE"
	fi
	
	verificarTipoDeLlamadaValida "$codigoPaisB" "$codigoAreaB" "$numeroB"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene un formato valido para el numero B." "$registro"
		return "$FALSE"
	fi
	
	verificarAgenteValido "$idAgente"
	if [ $? -eq "$FALSE" ]; then
		rechazarRegistro "Registro no tiene un id de agente valido." "$registro"
		return "$FALSE"
	fi
	
	verificarAreaValida "$codigoAreaA"
	if [ $? -eq "$FALSE" ]; then
		rechazarRegistro "Registro no tiene un codigo de Area A valido." "$registro"
		return "$FALSE"
	fi
	
	verificarSiEsNumero "$numeroA"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene un numero de linea A valido." "$registro"
		return "$FALSE"
	fi
	
	verificarSiHay10Digitos "$codigoAreaA" "$numeroA"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene 10 digitos en el area+numero del numero A." "$registro"
		return "$FALSE"
	fi
	
	determinarTipoDeLlamada "$codigoPaisB" "$codigoAreaB" "$numeroB" "$codigoAreaA"
	local tipoDeLlamada="$RETORNO"
	
	if [ "$tipoDeLlamada" == "$DDI" ]; then
		verificarPaisValido "$codigoPaisB"
		if [ $? -eq "$FALSE" ];then
			rechazarRegistro "Registro no tiene un codigo de pais valido y es DDI." "$registro"
			return "$FALSE"
		fi
	fi
	
	if [ "$tipoDeLlamada" != "$DDI" ] && [ "$codigoAreaB" != "" ];then
		verificarAreaValida "$codigoAreaB"
		if [ $? -eq "$FALSE" ]; then
			rechazarRegistro "Registro no tiene un codigo de area B valido." "$registro"
			return "$FALSE"
		fi
	fi
	
	verificarSiEsNumero "$numeroB"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene un numero de linea B valido." "$registro"
		return "$FALSE"
	fi
	
	if [ "$tipoDeLlamada" != "$DDI" ]; then
		verificarSiHay10Digitos "$codigoAreaB" "$numeroB"
		if [ $? -eq "$FALSE" ];then
			rechazarRegistro "Registro no tiene 10 digitos en el area+numero del numero B." "$registro"
			return "$FALSE"
		fi
	fi
	
	verificarSiEsNumero "$tiempoDeConversacion"
	if [ $? -eq "$FALSE" ];then
		rechazarRegistro "Registro no tiene un tiempo de conversacion valido." "$registro"
		return "$FALSE"
	fi
	
	if [ "$tiempoDeConversacion" -lt 0 ]; then
		rechazarRegistro "Registro no tiene un tiempo de conversacion mayor o igual a cero." "$registro"
		return "$FALSE"
	fi
	
	return "$TRUE"
}

obtenerUmbral(){
	local registro="$1"
	
	determinarTipoDeLlamada "$codigoPaisB" "$codigoAreaB" "$numeroB" "$codigoAreaA"
	local tipoDeLlamada="$RETORNO"
	
	local umbral=""
	local expresion='$6 < '$tiempoDeConversacion
	if [ "$tipoDeLlamada" == "$DDI" ]; then
		umbral=$(grep -e ".*;${codigoAreaA};${numeroA};DDI;${codigoPaisB};.*;Activo$" -e ".*;${codigoAreaA};${numeroA};DDI;;.*;Activo$" "$MAEDIR/umbrales.tab" \
		| awk -F';' "${expresion}" | head -n 1 | awk -F';' '{print $1}')
	else
		umbral=$(grep -e ".*;${codigoAreaA};${numeroA};${tipoDeLlamada};${codigoAreaB};.*;Activo$" -e ".*;${codigoAreaA};${numeroA};${tipoDeLlamada};;.*;Activo$" "$MAEDIR/umbrales.tab" \
		| awk -F';' "${expresion}" | head -n 1 | awk -F';' '{print $1}')
	fi
	
	RETORNO="$umbral"
			
}

verificarSiRegistroTieneUmbralesActivos(){
	local registro="$1"
	
	local umbrales=$(grep -c ".*;.*;$numeroA;.*;.*;.*;Activo" "$MAEDIR/umbrales.tab")

	if [ $umbrales -eq 0 ];then
		return "$FALSE"
	else
		return "$TRUE"
	fi
}


# $1 :Registro
# $2: Umbral
grabarLlamadaSospechosa(){
	local registro="$1"
	
	determinarTipoDeLlamada "$codigoPaisB" "$codigoAreaB" "$numeroB" "$codigoAreaA"
	local tipoDeLlamada="$RETORNO"
	
	local sospechosa
	sospechosa="$COD_CENTRAL;$idAgente;$umbral;$tipoDeLlamada;$inicioDeLlamada;$tiempoDeConversacion;$codigoAreaA;$numeroA;$codigoPaisB;$codigoAreaB;$numeroB;$NOMBRE_ARCHIVO"

	local oficina=$(grep ".*;.*;$idAgente;.*;.*" "$MAEDIR"/agentes.mae | head -n 1 | awk -F';' '{print $4}')
	
	local aniomes=$(echo "$inicioDeLlamada" | awk -F' ' '{ print $1 }' | awk -F'/' '{print $3$2}')
	echo "$sospechosa" >> "$PROCDIR/${oficina}_${aniomes}"
	
}

# $1: Registro a procesar
procesarRegistro(){
	local registro="$1"
	idAgente=$(echo "$registro" | cut -d';' -f1)
	inicioDeLlamada=$(echo "$registro" | cut -d';' -f2)
	tiempoDeConversacion=$(echo "$registro" | cut -d';' -f3)
	codigoAreaA=$(echo "$registro" | cut -d';' -f4)
	numeroA=$(echo "$registro" | cut -d';' -f5)
	codigoPaisB=$(echo "$registro" | cut -d';' -f6)
	codigoAreaB=$(echo "$registro" | cut -d';' -f7)
	numeroB=$(echo "$registro" | cut -d';' -f8)
	
	verificarRegistro "$registro"
	if [ $? -eq "$FALSE" ]; then
		let LLAMADAS_RECHAZADAS++
		return "$FALSE"
	fi
	
	verificarSiRegistroTieneUmbralesActivos "$registro"
	if [ $? -eq "$FALSE" ]; then
		let LLAMADAS_SIN_UMBRAL++
		return "$FALSE"
	fi
	
	let LLAMADAS_CON_UMBRAL++
	obtenerUmbral "$registro"
	local umbral="$RETORNO"
	if [ "$umbral" == "" ]; then
		let LLAMADAS_NOSOSPECHOSAS++
		return "$TRUE"
	fi
	let LLAMADAS_SOSPECHOSAS++
	grabarLlamadaSospechosa "$registro" "$umbral"
	
	return "$FALSE"		
}

procesarArchivo(){
	local archivo="$1"
	Loguear "Archivo a procesar: $(basename "$archivo")"
	
	IFS=$'\n'
	for line in $(cat $archivo);do
		procesarRegistro "$line"
		let LLAMADAS++
	done
	
	return
	#while read line; do
	#done <<< "$(cat $archivo)"
}

setearVariablesGlobales(){
	NOMBRE_ARCHIVO="$1"
	COD_CENTRAL=$(echo "$1" | cut -d'_' -f1)
	ANIOMESDIA=$(echo "$1" | cut -d'_' -f2)
	
	LLAMADAS=0
	LLAMADAS_SIN_UMBRAL=0
	LLAMADAS_CON_UMBRAL=0
	LLAMADAS_SOSPECHOSAS=0
	LLAMADAS_NOSOSPECHOSAS=0
	LLAMADAS_RECHAZADAS=0
}

grabarEstadisticas(){
	Loguear "
	Cantidad de llamadas = $LLAMADAS: Rechazadas $LLAMADAS_RECHAZADAS , Con umbral = $LLAMADAS_CON_UMBRAL , Sin umbral = $LLAMADAS_SIN_UMBRAL
	Cantidad de llamadas sospechosas $LLAMADAS_SOSPECHOSAS , no sospechosas $LLAMADAS_NOSOSPECHOSAS
	"
	
}

main(){
	obtenerCantidadDeArchivos "$ACEPDIR"
	local cantidad="$RETORNO"
	Loguear "Inicio DE AFRAUMBR"
	Loguear "Cantidad de archivos a procesar: $cantidad"
	
	archivosProcesados=0
	archivosRechazados=0
	
	archivos=$(ls "$ACEPDIR" | grep ".*_[0-9]\+" | sort -t"_" -k2)
				
	for doc in $archivos;do
		if [ ! -z "$doc" ]; then
			verificarSiArchivoOK "$ACEPDIR/$doc"
			if [ $? -eq "$TRUE" ];then
				let archivosProcesados++
				setearVariablesGlobales "$doc" # Pasar solo el nombre, no la ruta
				procesarArchivo "$ACEPDIR/$doc"
				"$BINDIR"/MOVERA.sh "$ACEPDIR/$doc" "$PROCDIR/proc" "AFRAUMBR"
				grabarEstadisticas
			else
				let archivosRechazados++
			fi
		fi
	done
	
	Loguear "Cantidad de archivos procesados: $archivosProcesados"
	Loguear "Cantidad de archivos rechazados: $archivosRechazados"
	Loguear "Fin de AFRAUMBR"
	
}

main

