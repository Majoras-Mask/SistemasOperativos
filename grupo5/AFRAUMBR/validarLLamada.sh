#!/bin/bash
source clasificarLLamada.sh
source parserLLamada.sh

#mover esto a un
# archivo de configuracion
DIRLLAMADAS="ACEPDIR/"
DIRCDA="/CdA.mae"
DIRCDP="/CdP.mae"
AGENTES="/agentes.mae"
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
	idAgente=$(echo "$idAgente"| sed 's/ //g')
	linea=$(echo $linea | sed 's/ //g')
	idEsValido=$(echo "$linea" | sed -e "s/^"$idAgente";/:/" -e "s/;"$idAgente";/:/" -e "s/;"$idAgente"$/:/" | grep :)
	if [ "$idEsValido" != "" ]
	then

	return 1
	fi

done < "$MAEDIR$AGENTES"
return 0
}

validarTiempoConversacion() 
{
	local tiempoConversacion="$1"
if  [ "$tiempoConversacion" -lt 0 ]
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
        done < "$MAEDIR$DIRCDA"
return 0
}

validarNumeroLineaA()
{
local numeroLineaA="$1"
local codigoAreaA="$2"

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
	local status=1
	esNumerico=$( echo "$numeroLineaB" | sed 's/[0-9]*//')
	if [ "$esNumerico" != "" ]
	then
		echo "linea b no numerico"
		eval "numeroLineaBValido='$NUMERO_LINEA_DESTINO_NO_NUMERICO'"
		status=0
	else
		esDDI "$numeroPaisB"
		local res="$?"
		if [ "$res" -eq 1 ]
		then
			llamadaDDIvalida "$numeroPaisB"
			local res1="$?"
			if [ "$res1" -eq  0 ]
			then
				eval "numeroPaisBValido='$CODIGO_PAIS_INEXISTENETE'"
				status="$res1"
			fi
			
		else 
			if [ "$numeroAreaB" != "" ]
			then
				validarCodigoArea "$numeroAreaB"
				local res2="$?"
				if [ "$res2" -eq 0 ] 
				then
					eval "numeroAreaBValido='$CODIGO_AREA_DESTINO_INEXISTENTE'"
					status="$res2"
				fi
			else
				codigoAreaBNumeroLinea="$numeroLineaB$numeroAreaB"
				if [ ${#codigoAreaBNumeroLinea} -ne 10 ]
					then
					echo "numero area = $numeroAreaB"
					echo "numero linea = $numeroLineaB"
					eval "numeroLineaBValido='$NUMERO_LINEA_DESTINO_INCORRECTO'"
					status=0
				fi
			fi	
		fi
	fi		
return `expr $status`
}

 validarLLamada()
{

local registroLLamada="$1"
registroErrores="$2"
local idAgente
local fechaYHora
local numeroAreaA
local numeroLineaA
local numeroPaisB
local numeroAreaB
local numeroLineaB
local tiempoConversacion
parsearLLamada "$registroLLamada" idAgente fechaYHora umeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
llamadaValida="$LLAMADA_VALIDA"
idAgenteValido="$VALIDO"
numeroAreaAValido="$VALIDO"
numeroLineaAValido="$VALIDO"
numeroAreaBValido="$VALIDO"
numeroPaisBValido="$VALIDO"
numeroLineaBValido="$VALIDO"
tiempoConversacionValido="$VALIDO"

validarIdAgente "$idAgente"
	local idAgenteEsValido=$?
	if [ $idAgenteEsValido -eq 0 ]
	then
	idAgenteValido="$ID_AGENTE_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
	fi


validarCodigoArea "$numeroAreaA"
local areaAEsValida="$?"
if [ "$areaAEsValida" -eq 0 ] 
then
	numeroAreaAValido="$CODIGO_AREA_ORIGEN_INEXISTENTE"
	llamadaValida="$LLAMADA_INVALIDA"
fi

validarNumeroLineaA "$numeroLineaA" "$numeroAreaA"
local numeroLineaAEsValido="$?"
if [ "$numeroLineaAEsValido" -eq 0 ]
then
	llamadaValida="$LLAMADA_INVALIDA"
fi


validarNumeroLineaB "$numeroLineaB" "$numeroPaisB" "$numeroAreaB"
local numeroLineaBEsValido="$?"

if [ "$numeroLineaBEsValido" -eq 0 ]
then
	llamadaValida="$LLAMADA_INVALIDA"
fi

tiempoConversacion=`expr $tiempoConversacion`
validarTiempoConversacion "$tiempoConversacion"
local tiempoConversacionEsValido=$?
if [ "$tiempoConversacionEsValido" -eq 0 ]
then
	tiempoConversacionValido="$ERROR_TIEMPO_DE_CONVERSACION"
	llamadaValida="$LLAMADA_INVALIDA"
fi
eval "registroErrores='$llamadaValida;$idAgenteValido;$numeroAreaAValido;$numeroLineaAValido;\
$numeroPaisBValido;$numeroAreaBValido;$numeroLineaBValido;$tiempoConversacionValido'"
}

export -f validarLLamada

