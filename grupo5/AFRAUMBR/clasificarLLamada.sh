#!/bin/bash
export ES_DDI="DDI"
export ES_DDN="DDN"
export ES_LOCAL="LOC"
DIRCDP="/CdP.mae"
source "$BINDIR"/parserLLamada.sh

llamadaDDIvalida()
{
local codigoPaisB="$1"
local linea

while read linea || [ -n "$linea" ]
	do
	     local es_DDI=$(echo $linea | awk -F ';' '{ print $1 }' )
	     if [ "$es_DDI" == "$codigoPaisB" ]
	     	then 
	     		return 1
	     fi
	done < "$MAEDIR$DIRCDP"
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
	esDDNLocal="$3"
	if [ "$codigoAreaA"=="$codigoAreaB" ]
	then
		eval "$esDDNLocal='$ES_LOCAL'"
		return 1
	fi
	eval "$esDDNLocal='$ES_DDN'"
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
	esDDI "$codigoPaisB"
	local es_DDi="$?"
	if [ "$es_DDi" -eq 1 ]
	then	
		eval "tipoLLamada='$ES_DDI'"
		return 1
	fi
	esDDNOLocal "$codigoAreaA" "$codigoAreaB" esDDNLOCAL
	eval "tipoLLamada='$esDDNLOCAL'"
	return 1	
}

export -f esDDI
export -f clasificarLLamada
