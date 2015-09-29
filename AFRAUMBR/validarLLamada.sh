#!/bin/bash
source clasificarLLamada.sh
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
local idAgente="$1"
local linea
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
	local tiempoConversacion="$1"
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
	local linea
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
local numeroLineaA="$1"
local codigoAreaA="$2"
local codigoAreaAValido="$3"
local numeroLineaAValido="$4"

local areaEsNumerica=$( echo "$codigoAreaA" | grep "^-\?[0-9]*$")
local lineaEsNumerica=$(echo "$numeroLineaA" | grep "^-\?[0-9]*$")
if [ "$areaEsNumerica" == "" ] 
	then
	eval "codigoAreaAValido='$CODIGO_AREA_ORIGEN_NO_NUMERICO'" 
fi
if  [ "$lineaEsNumerica" == "" ]
then
	eval "numeroLineaAValido='$NUMERO_LINEA_ORIGEN_NO_NUMERICO'"
	return 0
fi
local numeroACompleto="$codigoAreaA$numeroLineaA"
if [ ${#numeroACompleto} -ne 10 ]
then
	eval "numeroAreaAValido='$NUMERO_LINEA_ORIGEN_INCORRECTO'"
	eval "numeroLineaAValido='$NUMERO_LINEA_ORIGEN_INCORRECTO'"
	return 0
fi
return 1
}

validarNumeroLineaB() 
{
	local numeroLineaB="$1"
	local numeroPaisB="$2"
	local numeroAreaB="$3"
	local numeroAreaBValido="$4"
	local numeroPaisBValido="$5"
	local numeroLineaBValido="$6"
	local status=1
	esNumerico=$( echo "$numeroLineaB" | sed 's/[0-9]*//')
	if [ "$esNumerico" != "" ]
	then
		echo " esto no deberia suceder"
		eval "numeroLineaBValido='$NUMERO_LINEA_DESTINO_NO_NUMERICO'"
		status=0
	fi
	esNumerico=$( echo "$numeroAreaB" | sed 's/[0-9]*//')
	if [ "$esNumerico" != "" ]
	then
	echo "area destino no numerico"
	eval "$numeroAreaBValido='$CODIGO_AREA_DESTINO_NO_NUMERICO'"
	status=0
	else
		esDDI "$numeroPaisB"
		res="$?"
		if [ "$res" -eq 1 ]
		then
			llamadaDDIvalida "$numeroPaisB"
			res1="$?"
			echo "numeroPaisB = $numeroPaisB"
			echo "res1 = $res1" 
			if [ "$res1" -eq  0 ]
			then
				eval "numeroPaisBValido='$CODIGO_PAIS_INEXISTENETE'"
				status="$res1"
			fi
			validarCodigoArea "$numeroAreaB"
			res2="$?"
			if [ "$res2" -eq 0 ] 
			then
				eval "numeroAreaB='$CODIGO_AREA_DESTINO_INEXISTENTE'"
				status="$res2"
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

local registroLLamada="$1"
registroErrores="$2"

parsearLLamada "$registroLLamada" idAgente numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
llamadaValida="$LLAMADA_VALIDA"
local idAgenteValido="$VALIDO"
local numeroAreaAValido="$VALIDO"
local numeroLineaAValido="$VALIDO"
local numeroAreaBValido="$VALIDO"
local numeroPaisBValido="$VALIDO"
local numeroLineaBValido="$VALIDO"
local tiempoConversacionValido="$VALIDO"
#echo "numeroAreaA = $numeroAreaA"
#echo "numeroLineaA = $numeroLineaA"
#echo "numeroPaisB = $numeroPaisB"
#echo "numeroAreaB = $numeroAreaB"
#echo "numeroLineaB = $numeroLineaB"
#echo "tiempo de conversacion = $tiempoConversacion"
validarIdAgente "$idAgente"
	local idAgenteEsValido=$?
	if [ $idAgenteEsValido -eq 0 ]
	then
	idAgenteValido="$ID_AGENTE_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
	echo " id de agente incorrecto"
	fi


validarCodigoArea "$numeroAreaA"
local areaAEsValida="$?"
if [ "$areaAEsValida" -eq 0 ] 
then
	echo "area origen no es valida"
	numeroAreaAValido="$CODIGO_AREA_ORIGEN_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
fi

validarNumeroLineaA "$numeroLineaA" "$numeroAreaA" "$numeroAreaAValido" "$numeroLineaAValido"
local numeroLineaAEsValido="$?"
if [ "$numeroLineaAEsValido" -eq 0 ]
then
	echo "numero llamada origen no es valida"
	llamadaValida="$LLAMADA_INVALIDA"
fi


#echo "ajajajajajaja"
validarNumeroLineaB "$numeroLineaB" "$numeroPaisB" "$numeroAreaB" "$numeroAreaBValido" "$numeroPaisBValido" "$numeroLineaBValido"
local numeroLineaBEsValido="$?"
#echo "numero linea b  es valido = $numeroLineaBValido"
if [ "$numeroLineaBEsValido" -eq 0 ]
then
	#echo "numero llamada destino es invalido"
	echo "numeroAreaBValido = $numeroAreaBValido"
	echo "numeroLineaBValido = $numeroLineaBValido"
	echo "numeroPaisBValido = $numeroPaisBValido" 
	llamadaValida="$LLAMADA_INVALIDA"
fi

tiempoConversacion=`expr $tiempoConversacion`
validarTiempoConversacion "$tiempoConversacion"
local tiempoConversacionEsValido=$?
if [ "$tiempoConversacionEsValido" -eq 0 ]
then
	echo "tiempo conversacion incorrecto"
	tiempoConversacionValido="$ERROR_TIEMPO_DE_CONVERSACION"
	llamadaValida="$LLAMADA_INVALIDA"
fi
eval "registroErrores='$llamadaValida;$idAgenteValido;$numeroAreaAValido;$numeroLineaAValido;\
$numeroPaisBValido;$numeroAreaBValido;$numeroLineaBValido;$tiempoConversacionValido'"
echo "llamadaValida = $llamadaValida"

#echo "numeroAreaAValido = $numeroAreaAValido"
#echo "numeroLineaAValido = $numeroLineaAValido"
#echo "numeroPaisBValido = $numeroPaisBValido"
#echo "numeroAreaBValido = $numeroAreaBValido"
#echo "numeroLineaBValido = $numeroLineaBValido"
#echo "tiempo de conversacion valido = $tiempoConversacionValido"
}

export -f validarLLamada

