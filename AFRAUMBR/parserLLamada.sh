#!/bin/bash

parsearLLamada() 
{

	local lineaLLamada="$1"
	idAgente="$2"
	fechaYHora="$3"
	numeroAreaA="$4"
	numeroLineaA="$5"
	numeroPaisB="$6"
	numeroAreaB="$7"
	numeroLineaB="$8"
	tiempoConversacion="$9"	

	eval "idAgente='$(echo "$lineaLLamada" | awk -F ';' ' { print $1 }')'"
	eval "fechaYHora='$(echo "$lineaLLamada" | awk -F ';' ' { print $2 }')'"
	eval "tiempoConversacion='$(echo "$lineaLLamada" | awk -F ';' ' { print $3}')'"
	eval "numeroAreaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $4 }')'"
	eval "numeroLineaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $5 }')'"
	eval "numeroPaisB='$(echo "$lineaLLamada" | awk -F ';' ' { print $6 }')'"
	eval "numeroAreaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $7 }')'"
	eval "numeroLineaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $8 }')'"
	
}

parsearCodigosDeArea()
{
	local lineaLLamada="$1"
	codigoAreaA="$2"
	codigoPaisB="$3"
	codigoAreaB="$4"
	eval "codigoAreaA='$(echo "$lineaLLamada" | awk -F ';' ' { print $3 }')'"
	eval "codigoPaisB='$(echo "$lineaLLamada" | awk -F ';' ' { print $6 }')'"
	eval "codigoAreaB='$(echo "$lineaLLamada" | awk -F ';' ' { print $7 }')'"
}

export -f parsearLLamada