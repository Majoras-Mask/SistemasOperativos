#!/bin/bash

parsearLLamada() 
{

	local lineaLLamada="$1"
	idAgente="$2"
	numeroAreaA="$3"
	numeroLineaA="$4"
	numeroPaisB="$5"
	numeroAreaB="$6"
	numeroLineaB="$7"
	tiempoConversacion="$8"	

	eval "idAgente='$(echo "$lineaLLamada" | awk -F ';' ' { print $1 }')'"
	eval "numeroAreaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $2 }')'"
	eval "numeroLineaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $3 }')'"
	eval "numeroPaisB='$(echo "$lineaLLamada" | awk -F ';' ' { print $4 }')'"
	eval "numeroAreaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $5 }')'"
	eval "numeroLineaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $6 }')'"
	eval "tiempoConversacion='$(echo "$lineaLLamada" | awk -F ';' ' { print $7}')'"
}

parsearCodigosDeArea()
{
	local lineaLLamada="$1"
	codigoAreaA="$2"
	codigoPaisB="$3"
	codigoAreaB="$4"
	echo "linea lineaLLamada = $lineaLLamada"
	#echo "$lineaLLamada" | awk -F ';' ' { print $2 }'
	#echo "$lineaLLamada" | awk -F ';' ' { print $4 }'
	#echo "$lineaLLamada" | awk -F ';' ' { print $5 }'
	eval "codigoAreaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $2 }')'"
	eval "codigoPaisB='$(echo "$lineaLLamada" | awk -F ';' ' { print $4 }')'"
	eval "codigoAreaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $5 }')'"
}

export -f parsearLLamada