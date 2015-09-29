#!/bin/bash
ES_DDI="DDI"
ES_DDN="DDN"
ES_LOCAL="LOCAL"
DIRCDP="MAEDIR/CdP.mae"
DIRLLAMADAS="ACEPDIR/"
DIRCDA="MAEDIR/CdA.mae"
DIRCDP="MAEDIR/CdP.mae"
AGENTES="MAEDIR/agentes.mae"
DIRLLAMADAS="ACEPDIR/"
LLAMADA_VALIDA="valido"
CODIGO_PAIS_INEXISTENETE=" El codigo de pais no existe"

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
		eval "$resultado='$ES_DDN'"
		return 1
	fi
	eval "$resultado='$ES_LOCAL'"
	return 1
}

clasificarLLamada()
{
	local codigoAreaA="$1"
	local codigoPaisB="$2"
	local codigoAreaB="$3"
	resultado="$4"
	local esDDI "$codigoPaisB"
	e_DDi="$?"
	if [ "$es_DDi" -eq 1 ]
	then	
		eval "$resultado='$ES_DDI'"
		return 1
	fi
	esDDNOLocal "$codigoAreaA" "$codigoAreaB" esDDNLOCAL
	eval "$resultado='$esDDNLOCAL'"
	return 1	
}

export -f esDDI
