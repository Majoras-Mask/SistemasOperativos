#!/bin/bash

GRUPO="$PWD"
MAEDIR="MAEDIR"
BINDIR="BINDIR"
# Variable CONFDIR, directorio de configuracion
CONFDIR="$PWD/conf"
NOVEDIR="NOVEDIR"
RECHDIR="RECHDIR"
REPODIR="REPODIR"
ACEPDIR="ACEPDIR"
PROCDIR="PROCDIR"
LOGDIR="LOGDIR"

# Archivos a generar en este script
LOGFILE="AFRAINIC.log"
RETORNO=""

Loguear(){
    echo "$1"
    echo "$1" >> "$LOGDIR/$LOGFILE"
}

LeerInput(){
    read input
    echo "$input" >> "$LOGDIR/$LOGFILE"
}

LeerSiONo(){
    local mensaje=$1
    while true; do
        Loguear "$mensaje"
        LeerInput
        
        if [ $input = "Si" -o $input == "SI" -o $input == "si" -o $input == "Y"\
            -o $input == "y" -o $input == "Yes" ]; 
        then
            RETORNO="Si"
            return 0
        elif [ $input == "No" -o $input == "NO" -o $input == "no" \
            -o $input == "n" ];
        then
            RETORNO="No"
            return 0
        fi
    done
}

loguearVariables(){
	local listar=("$CONFDIR" "$BINDIR" "$MAEDIR" "$LOGDIR")
	local tipoDir=('Configuración' 'Ejecutables' 'Maestros y Tablas' 'Archivos de Log')
	
	for(( i=0;i<${#listar[@]};i++ )); do
		Loguear "Directorio de ${tipoDir[${i}]}: $GRUPO/${listar[${i}]}"
		Loguear "$(ls "$GRUPO/${listar[${i}]}")"
	done

	local listar2=("$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$RECHDIR")
	local tipoDir2=('recepcion de archivos de llamamdas' 'Archivos de llamadas Aceptados' 'Archivos de llamadas Sospechosas' 'Archivos de Reportes de llamadas' 'Archivos Rechazados')
	
	for(( i=0;i<${#listar2[@]};i++ )); do
		Loguear "Directorio de ${tipoDir2[${i}]}: $GRUPO/${listar2[${i}]}"
	done
	
	Loguear "Estado de Sistema: INICIALIZADO"
}

verificaInstalacionCompleta(){

	MAEDIR=$(grep '^MAEDIR' $CONFDIR | cut -d '=' -f 2)
	local archivos=('CdP.mae' 'CdA.mae' 'CdC.mae' 'agentes.mae' 'tllama.tab' 'umbral.tab')
	local cant=${#archivos[@]}
	local faltantes=()

	for(( i=0; i<$cant; i++ )); do
		if ! [ -f "$MAEDIR/${archivos[${i}]}" ]; then
			faltantes[${i}]="${archivos[${i}]}"
		fi
	done
	
	if [ ${#faltantes}[@] -ne 0 ]; then
		echo "Archivos faltantes en la instalación: ${faltantes[@]}\n"
		echo "Ejecute instalador...................................."
 	fi
}

verificarPermisos(){
	BINDIR=$(grep '^BINDIR' $CONFDIR | cut -d '=' -f 2)
	MAEDIR=$(grep '^MAEDIR' $CONFDIR | cut -d '=' -f 2)
	
	for file in $(ls "$BINDIR"); do
		if ! [ -x "$BINDIR/$file" ]; then
			chmod +x "$BINDIR/$file"
			if [ "$?" = -1  ]; then
      				Loguear "No se pudo setear los permisos de $BINDIR/$file"     
    			fi
		fi			
	done

	for file in $(ls "$MAEDIR"); do
		if ! [ -r "$MAEDIR/$file" ]; then
			chmod +r "$MAEDIR/$file"
			if [ "$?" = -1  ]; then
                                Loguear "No se pudo setear los permisos de $MAEDIR/$file"
			fi

		fi
	done
}		

inicializarAmbiente(){
	GRUPO=$(grep '^GRUPO' $CONFDIR | cut -d '=' -f 2)
	CONFDIR=$(grep '^CONFDIR' $CONFDIR | cut -d '=' -f 2)
	BINDIR=$(grep '^BINDIR' $CONFDIR | cut -d '=' -f 2)
	MAEDIR=$(grep '^MAEDIR' $CONFDIR | cut -d '=' -f 2)
	DATASIZE=$(grep '^DATASIZE' $CONFDIR | cut -d '=' -f 2)
	ACEPDIR=$(grep '^ACEPDIR' $CONFDIR | cut -d '=' -f 2)
	RECHDIR=$(grep '^RECHDIR' $CONFDIR | cut -d '=' -f 2)
	PRODIR=$(grep '^PROCDIR' $CONFDIR | cut -d '=' -f 2)
	REPDIR=$(grep '^REPODIR' $CONFDIR | cut -d '=' -f 2)
	NOVDIR=$(grep '^NOVEDIR' $CONFDIR | cut -d '=' -f 2)
	LOGDIR=$(grep '^LOGDIR' $CONFDIR | cut -d '=' -f 2)
	LOGSIZE=$(grep '^LOGSIZE' $CONFDIR | cut -d '=' -f 2)
	
	#falta inicializar PATH: no tengo idea que poner ahi.
}
	


arrancarAFRAECI(){

	LeerSiONo "¿Desea efectuar la activación de AFRARECI? Si – No"
	if[ $RETORNO == "No" ]; then
		echo "Debe ingresar el comando ARRANCAR <parametros> por consola."
	else	
		if [ "$(pidof ARRANCAR.sh)" ]; then  #utilizar variable de ambiente
			echo "Proceso ARRACAR ya iniciado. Debe utilizar el comando DETENER para terminarlo"
		else
			./ARRANCAR.sh &
			ID=$!
			Loguear "AFRARECI corriendo bajo el no.: $ID" 
		fi
	fi
	


}

Inicializar(){
        if ["$(pidof AFRAINIC.sh)"]; then
                echo "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"  
        else
		verificaInstalacionCompleta
		verificarPermisos
		inicializarAmbiente
		loguearVariables
		arrancarAFRAECI
	fi	
}

Inicializar
