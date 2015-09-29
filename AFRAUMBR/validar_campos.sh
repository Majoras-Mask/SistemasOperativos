#!/bin/bash
#mover esto a un
# archivo de configuracion
CANTIDAD_CAMPOS_INCORRECTOS="La cantidad de campos correspondiente a la \
llamada no es correcta"
source validar_llamada.sh

validarArchivoLlamada()
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

validarCampos() 
{	

	lineaAParsear="$1"
	registroErrores="$2"

	cantidadCampos=$(echo "$lineaAParsear" | awk -F ';' '{print NF}')
	if [ "$cantidadCampos" -ne 7 ] 
	then
		return 0
	fi	
	validarLLamada "$linea" "$registroErrores"
	return 1
}



export -f validarCampos

export -f validarArchivoLlamada

