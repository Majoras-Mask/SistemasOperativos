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

llamada_ddi_valida()
{
codigoPaisB="$1"
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


es_ddi()
{
	codigoPaisB="$1"
	if [ "$codigoPaisB" == "" ]
	then
		return 0
	fi
	
return 1
}

es_ddn_o_local() 
{
	codigoAreaA="$1"
	codigoAreaB="$2"
	resultado="$3"
	if [ "$codigoAreaA"=="$codigoAreaB" ]
	then
		eval "$resultado='$ES_DDN'"
		return 1
	fi
	eval "$resultado='$ES_LOCAL'"
	return 1
}

clasificar_llamada()
{
	codigoAreaA="$1"
	codigoPaisB="$2"
	codigoAreaB="$3"
	resultado="$4"
	es_ddi "$codigoPaisB"
	es_DDI="$?"
	if [ "$es_DDI" -eq 1 ]
	then	
		eval "$resultado='$ES_DDI'"
		return 1
	fi
	es_ddn_o_local "$codigoAreaA" "$codigoAreaB" esDDN_LOCAL
	eval "$resultado='$esDDN_LOCAL'"
	return 1	
}

export -f es_ddi
