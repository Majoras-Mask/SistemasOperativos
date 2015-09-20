#!/bin/bash

function parsearLLamada 
{

	lineaLLamada="$1"
	idAgente="$2"
	numeroAreaA="$3"
	numeroLineaA="$4"
	numeroPaisB="$5"
	numeroAreaB="$6"
	numeroLineaB="$7"
	tiempoConversacion="$8"	

	eval idAgente="'$(echo "$lineaLLamada" | awk -F ';' ' { print $1 }')'"
	eval numeroAreaA="'$(echo "$lineaLLamada" | awk -F ';' ' { print $2 }')'"
	eval numeroLineaA="'$(echo "$lineaLLamada" | awk -F ';' ' { print $3 }')'"
	eval numeroPaisB="'$(echo "$lineaLLamada" | awk -F ';' ' { print $4 }')'"
	eval numeroAreaB="'$(echo "$lineaLLamada" | awk -F ';' ' { print $5 }')'"
	eval numeroLineaB="'$(echo "$lineaLLamada" | awk -F ';' ' { print $6 }')'"
	eval tiempoConversacion="'$(echo "$lineaLLamada" | awk -F ';' ' { print $7}')'"

	#echo "numeroAreaA = $numeroAreaA"
	#echo "numeroLineaA = $numeroLineaA"
	#echo "numeroPaisB = $numeroPaisB"
	#echo "numeroAreaB = $numeroAreaB"
	#echo "numeroLineaB = $numeroLineaB"
	#echo "tiempo de conversacion = $tiempoConversacion" 
}

export -f parsearLLamada