#!/bin/bash
#mover esto a un
# archivo de configuracion
export CANTIDAD_CAMPOS_INCORRECTOS="La cantidad de campos correspondiente a la \
llamada no es correcta"
source "$BINDIR/"validarLLamada.sh

validarArchivoLlamada()
{	

	nombre="$1"
	match=$(ls "$PROCDIR/proc"| grep "$nombre")
        if [ -z  "$match" ]
        then 
		 return 1
       fi
       return 0
	
}

validarCampos() 
{	

	local linea="$1"
	registroErrores="$2"
	registroLLamada="$3"
	cantidadCampos=$(echo "$linea" | awk -F ';' '{print NF}')
	if [ "$cantidadCampos" -ne 8 ] 
	then
		eval "registroErrores='$CANTIDAD_CAMPOS_INCORRECTOS'"
		"$BINDIR"/GRALOG.sh "AFRAUMBR" "Se rechaza el archivo porque su estructura no se corresponde con el formato esperado" "INFO"
		return 0
	fi	
	validarLLamada "$linea" registroErrores 
	return 1
}



export -f validarCampos

export -f validarArchivoLlamada

