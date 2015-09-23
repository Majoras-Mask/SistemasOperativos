#!/bin/bash
#mover esto a un
# archivo de configuracion
CANTIDAD_CAMPOS_INCORRECCTOS="La cantidad de campos correspondiente a la \
llamada no es correcta"
source validar_llamada.sh

function validarArchivoLlamada
{	

	nombre="$1"
    PROCDIR="PROCDIR/proc/"	
	match=$(ls "$PROCDIR"| grep "$nombre")
        if [ -z  "$match" ]
        then 
		 return 1
       fi
       return 0
	
}

function validarCampos 
{	

	linea="$1"
	resultado="$2"

	cantidadCampos=$(echo "$linea" | awk -F ';' '{print NF}')
	if [ "$cantidadCampos" -ne 7 ] 
	then
		eval "$resultado='$CANTIDAD_CAMPOS_INCORRECCTOS'"
		return 0
	fi	
	validarLLamada "$linea" resultado
	eval "echo $resultado"
	return 1
}



export -f validarCampos

export -f validarArchivoLlamada

