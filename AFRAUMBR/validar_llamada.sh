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
NUMERO_LINEA_ORIGEN_NO_NUMERICO=" El numero de linea origen no es un valor \
numerico valido"
NUMERO_LINEA_DESTINO_NO_NUMERICO=" El numero de linea destino no es un valor \
numerico valido"
NUMERO_LINEA_DESTINO_INCORRECTO=" El numero de linea destino no suma 10 \
digitos con el codigo de area destino"
ERROR_TIEMPO_DE_CONVERSACION="El tiempo  de conversacion debe ser un \
numero mayor o igual a 0"
LLAMADA_VALIDA="valido"

function validarIdAgente
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


function validarTiempoConversacion 
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

function validarCodigoArea
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

function validarNumeroLineaA
{

numeroLineaA="$1"
codigoAreaA="$2"
resultado="$3"
areaEsNumerica=$( echo "$codigoAreaA" | grep "^-\?[0-9]*$")
lineaEsNumerica=$(echo "$numeroLineaA" | grep "^-\?[0-9]*$")
if [ "$areaEsNumerica" == "" ] && [ "$lineaEsNumerica" == "" ]
then
	eval "$resultado='$NUMERO_LINEA_ORIGEN_NO_NUMERICO'"
	return 0
fi
numeroACompleto="$codigoAreaA$numeroLineaA"
if [ ${#numeroACompleto} -ne 10 ]
then
	eval "$resultado='$NUMERO_LINEA_ORIGEN_INCORRECTO'" 
	return 0
fi
eval "$resultado='$LLAMADA_VALIDA'"
return 1
}

function validarNumeroLineaB 
{
	numeroLineaB="$1"
	numeroPaisB="$2"
	numeroAreaB="$3"
	resultado="$4"
	
	esNumerico=$( echo "$numeroLineaB" | sed 's/[0-9]*//')
	#echo "es numerico $esNumerico"
	if [ "$esNumerico" != "" ]
	then
	#	echo " esto no deberia suceder"
		eval "$resultado='$NUMERO_LINEA_DESTINO_NO_NUMERICO'"
		return 0
	fi
	es_ddi "$numeroPaisB"
	res="$?"
	if [ "$res" -eq 0 ]
	then
		eval "$resultado='$LLAMADA_VALIDA'"
		return 0
	fi

	validarCodigoArea "$numeroAreaB"
	areaAEsValida="$?"
	if [ "$areaAEsValida" -eq 0 ] 
	then
		eval "$resultado='$CODIGO_AREA_DESTINO_INEXISTENTE'"
		return 0
	fi

	codigoAreaBNumeroLinea="$numeroLineaB$numeroAreaB"
	#echo "numero b completo = $codigoAreaBNumeroLinea"
	#echo "size = ${#codigoAreaBNumeroLinea}"
	if [ ${#codigoAreaBNumeroLinea} -ne 10 ]
		then
		eval "$resultado='$NUMERO_LINEA_DESTINO_INCORRECTO'"
		return 0
	fi
	eval "$resultado='$LLAMADA_VALIDA'"
	return 1
}


function validarLLamada
{

lineaLLamada="$1"
resultado="$2"

parsearLLamada "$lineaLLamada" idAgente numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion

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
		eval "$resultado='$ID_AGENTE_INEXISTENTE'"
		return 0
	fi


validarCodigoArea "$numeroAreaA"
areaAEsValida="$?"
if [ "$areaAEsValida" -eq 0 ] 
then
	 eval "$resultado='$CODIGO_AREA_ORIGEN_INEXISTENTE'"
	 return 0
fi

validarNumeroLineaA "$numeroLineaA" "$area" numeroLineaAValido
if [ "$numeroLineaAValido" != "$LLAMADA_VALIDA"  ]
then
	eval "$resultado='$NUMERO_LINEA_ORIGEN_INCORRECTO'"
	return 0
fi

#echo "ajajajajajaja"
validarNumeroLineaB "$numeroLineaB" "numeroPaisB" "$numeroAreaB" resultado

#echo "numero linea b  es valido = $numeroLineaBValido"
if [ "$resultado" != "$LLAMADA_VALIDA" ]
then
	eval "$resultado"
	return 0
fi
echo "aja"
tiempoConversacion=`expr $tiempoConversacion`
validarTiempoConversacion "$tiempoConversacion"
tiempoConversacionEsValido=$?
if [ "$tiempoConversacionEsValido" -eq 0 ]
then
	eval "$resultado='$ERROR_TIEMPO_DE_CONVERSACION'"
	return 0
fi

eval "$resultado='$LLAMADA_VALIDA'"
return 1
}

export -f validarLLamada

