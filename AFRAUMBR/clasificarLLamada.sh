#!/bin/bash
ES_DDI="DDI"
ES_DDN="DDN"
ES_LOCAL="LOC"
DIRCDP="MAEDIR/CdP.mae"
DIRLLAMADAS="ACEPDIR/"
DIRCDA="MAEDIR/CdA.mae"
DIRCDP="MAEDIR/CdP.mae"
AGENTES="MAEDIR/agentes.mae"
DIRLLAMADAS="ACEPDIR/"
LLAMADA_VALIDA="valido"
CODIGO_PAIS_INEXISTENETE=" El codigo de pais no existe"
source parserLLamada.sh
llamadaDDIvalida()
{
local codigoPaisB="$1"
local linea
while read linea
	do
	     es_DDI=$(echo "$linea"| sed 's/;[A-Z]*[a-z]*//')
	     if [ "$es_DDI" == "$codigoPaisB" ]
	     	then 
	     	return 1
	     fi
	done < "$DIRCDP"
return 0
}


esDDI()
{
	local codigoPaisB="$1"
	if [ "$codigoPaisB" == "" ]
	then
		return 0
	fi
	
return 1
}

esDDNOLocal() 
{
	local codigoAreaA="$1"
	local codigoAreaB="$2"
	resultado="$3"
	if [ "$codigoAreaA"=="$codigoAreaB" ]
	then
		eval "$resultado='$ES_LOCAL'"
		return 1
	fi
	eval "$resultado='$ES_DDN'"
	return 1
}

clasificarLLamada()
{
	
	local lineaLLamada="$1"
	tipoLLamada="$2"

	local codigoAreaA
	local codigoPaisB
	local codigoAreaB
	parsearCodigosDeArea "$lineaLLamada" codigoAreaA codigoPaisB codigoAreaB
	#echo "$lineaLLamada"	
	echo "$codigoAreaA"
	echo "$codigoPaisB"
	echo "$codigoAreaB"
	esDDI "$codigoPaisB"
	local es_DDi="$?"
	if [ "$es_DDi" -eq 1 ]
	then	
		eval "tipoLLamada='$ES_DDI'"
		echo "resultado = $tipoLLamada"
		return 1
	fi
	local esDDNOLocal
	esDDNOLocal "$codigoAreaA" "$codigoAreaB" esDDNLOCAL
	eval "tipoLLamada='$esDDNLOCAL'"
	echo "tipoLLamada = $tipoLLamada"
	return 1	
}

export -f esDDI
export -f clasificarLLamada
