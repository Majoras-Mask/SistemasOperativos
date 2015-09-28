#!/bin/bash
source clasificar_llamada.sh
source parserLLamada.sh
#mover esto a un
# archivo de configuracion
DIRLLAMADAS="ACEPDIR/"
DIRCDA="MAEDIR/CdA.mae"
DIRCDP="MAEDIR/CdP.mae"
AGENTES="MAEDIR/agentes.mae"
DIRLLAMADAS="ACEPDIR/"
ID_AGENTE_INEXISTENTE=" el id de agente no es valido"
CODIGO_AREA_ORIGEN_INEXISTENTE="El codigo de area origen no es valido"
NUMERO_LINEA_ORIGEN_INCORRECTO=" El numero de linea de origen no suma 10 \
digitos con el codigo de area origen"
CODIGO_PAIS_INEXISTENETE=" El codigo de pais no existe"
CODIGO_AREA_DESTINO_INEXISTENTE="El codigo de area destino no es valido"
CODIGO_AREA_ORIGEN_NO_NUMERICO=" El numero de area origen no es un valor \
numerico valido"
NUMERO_LINEA_ORIGEN_NO_NUMERICO=" El numero de linea origen no es un valor \
numerico valido"
CODIGO_AREA_DESTINO_NO_NUMERICO=" El numero de area destino no es un valor \
numerico valido"
NUMERO_LINEA_DESTINO_NO_NUMERICO=" El numero de linea destino no es un valor \
numerico valido"
NUMERO_PAIS_DESTINO_NO_NUMERICO=" El codigo de pais destino no es un valor \
numerico valido"
NUMERO_LINEA_DESTINO_INCORRECTO=" El numero de linea destino no suma 10 \
digitos con el codigo de area destino"
ERROR_TIEMPO_DE_CONVERSACION="El tiempo  de conversacion debe ser un \
numero mayor o igual a 0"
VALIDO="valido"
LLAMADA_VALIDA="llamada valida"
LLAMADA_INVALIDA="llamada invalida"
validarIdAgente()
{
idAgente="$1"
while read linea
do
	#echo "linea = $linea"
	idEsValido=$(echo "$linea" | sed -e "s/^"$idAgente";/:/" -e "s/;"$idAgente";/:/" -e "s/;"$idAgente"$/:/" | grep :)
	#echo "idEsValido = $idEsValido"
	if [ "$idEsValido" != "" ]
	then
	return 1
	fi

done < "$AGENTES"
return 0
}

validarTiempoConversacion() 
{
	tiempoConversacion="$1"
if  [ "$tiempoConversacion" -lt 0 ]
then
	return 0
fi

if [ "$tiempoConversacion" -eq 0 ]
then 
	return 0
fi

return 1
}

validarCodigoArea()
{
while read  linea
do
       
        area=$(echo "$linea" | awk -F ';' ' { print $2 }')
        if [ "$area" == "$1" ]
        then
                return 1
        fi
        done < "$DIRCDA"
return 0
}

validarNumeroLineaA()
{

numeroLineaA="$1"
codigoAreaA="$2"
resultado="$3"
numeroLineaAValido="$4"
codigoAreaAValido="$5"
status=1
areaEsNumerica=$( echo "$codigoAreaA" | grep "^-\?[0-9]*$")
lineaEsNumerica=$(echo "$numeroLineaA" | grep "^-\?[0-9]*$")
if [ "$areaEsNumerica" == "" ] 
	then
	eval "codigoAreaAValido='$CODIGO_AREA_ORIGEN_NO_NUMERICO'" 
	status=0
fi
if  [ "$lineaEsNumerica" == "" ]
then
	eval "numeroLineaAValido='$NUMERO_LINEA_ORIGEN_NO_NUMERICO'"
	status=0
else 
	numeroACompleto="$codigoAreaA$numeroLineaA"
	if [ ${#numeroACompleto} -ne 10 ] && [ "$status" -eq 1 ]
	then
		eval "numeroAreaAValido='$NUMERO_LINEA_ORIGEN_INCORRECTO'"
		eval "numeroLineaAValido='$NUMERO_LINEA_ORIGEN_INCORRECTO'"
		status=0
	fi
fi
return `expr $status`
}

validarNumeroLineaB() 
{
	numeroLineaB="$1"
	numeroPaisB="$2"
	numeroAreaB="$3"
	numeroAreaBValido="$4"
	numeroPaisBValido="$5"
	numeroLineaBValido="$6"
	status=1
	esNumerico=$( echo "$numeroLineaB" | sed 's/[0-9]*//')
	if [ "$esNumerico" != "" ]
	then
	#	echo " esto no deberia suceder"
		eval "numeroLineaBValido='$NUMERO_LINEA_DESTINO_NO_NUMERICO'"
		status=0
	fi
	esNumerico=$( echo "$numeroAreaB" | sed 's/[0-9]*//')
	if [ "esNumerico" != "" ]
	then
	eval "$numeroAreaBValido='$CODIGO_AREA_DESTINO_NO_NUMERICO'"
	status=0
	else
		validarCodigoArea "$numeroAreaB"
		status="$?"
		if [ "$areaAEsValida" -eq 0 ] 
		then
			eval "numeroAreaB='$CODIGO_AREA_DESTINO_INEXISTENTE'"
		fi		
	fi 
	esNumerico=$( echo "$numeroPaisB" | sed 's/[0-9]*//')
	if [ "esNumerico" != "" ] 
	then
	eval "numeroPaisBValido='$NUMERO_PAIS_DESTINO_NO_NUMERICO'"
	status=0
	else 
		es_ddi "$numeroPaisB"
		res="$?"
		if [ "$res" -eq 1 ]
		then
			llamada_ddi_valida "$numeroPaisB"
			status="$?"
			if [ "$status" -eq  0 ]
			then
				eval "numeroPaisBValido='$CODIGO_PAIS_INEXISTENETE'"
			fi
		fi
	fi
	if [ "$status" -eq 1 ]
	then
		codigoAreaBNumeroLinea="$numeroLineaB$numeroAreaB"
		#echo "numero b completo = $codigoAreaBNumeroLinea"
		#echo "size = ${#codigoAreaBNumeroLinea}"
		if [ ${#codigoAreaBNumeroLinea} -ne 10 ]
			then
			eval "numeroLineaBValido='$NUMERO_LINEA_DESTINO_INCORRECTO'"
			status=0
		fi
	fi
	return `expr $status`
}

 validarLLamada()
{

registroLLamada="$1"
resultado="$2"

parsearLLamada "$registroLLamada" idAgente numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
llamadaValida="$LLAMADA_VALIDA"
idAgenteValido="$VALIDO"
numeroAreaAValido="$VALIDO"
numeroLineaAValido="$VALIDO"
numeroAreaBValido="$VALIDO"
numeroPaisBValido="$VALIDO"
numeroLineaBValido="$VALIDO"
tiempoConversacionValido="$VALIDO"
registroErrores="${llamadaValida}:${idAgenteValido}:${numeroAreaAValido}:${numeroLineaAValido}:\
${numeroPaisBValido}:${numeroAreaBValido}:${numeroLineaBValido}:${tiempoConversacionValido}"
#echo "numeroAreaA = $numeroAreaA"
#echo "numeroLineaA = $numeroLineaA"
#echo "numeroPaisB = $numeroPaisB"
#echo "numeroAreaB = $numeroAreaB"
#echo "numeroLineaB = $numeroLineaB"
#echo "tiempo de conversacion = $tiempoConversacion"
validarIdAgente "$idAgente"
	idAgenteEsValido=$?
	if [ $idAgenteEsValido -eq 0 ]
	then
	idAgenteValido="$ID_AGENTE_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
	fi


validarCodigoArea "$numeroAreaA"
areaAEsValida="$?"
if [ "$areaAEsValida" -eq 0 ] 
then
	numeroAreaAValido="$CODIGO_AREA_ORIGEN_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
fi

validarNumeroLineaA "$numeroLineaA" "$area"
numeroLineaAEsValido="$?"
if [ "$numeroLineaAEsValido" -eq 0 ]
then
	numeroLineaAValido="$NUMERO_LINEA_ORIGEN_INCORRECTO"
	llamadaValida="$LLAMADA_INVALIDA"
fi


#echo "ajajajajajaja"
validarNumeroLineaB "$numeroLineaB" "$numeroPaisB" "$numeroAreaB" "$numeroAreaBValido" "$numeroPaisBValido" "$numeroLineaBValido"
numeroLineaBEsValido="$?"
#echo "numero linea b  es valido = $numeroLineaBValido"
if [ "$numeroLineaBEsValido" -eq 0 ]
then
	llamadaValida="$LLAMADA_INVALIDA"
fi

echo "aja"
tiempoConversacion=`expr $tiempoConversacion`
validarTiempoConversacion "$tiempoConversacion"
tiempoConversacionEsValido=$?
if [ "$tiempoConversacionEsValido" -eq 0 ]
then
	tiempoConversacion="$ERROR_TIEMPO_DE_CONVERSACION"
	llamadaValida="$LLAMADA_INVALIDA"
fi
eval "resultado='$registroLLamada'"
}

export -f validarLLamada

