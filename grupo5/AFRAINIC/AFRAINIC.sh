#!/bin/bash

GRUPO="$PWD"
MAEDIR="MAEDIR"
# Variable CONFDIR, directorio de configuracion
CONF=$(echo "$PWD" | sed -n 's-^\(.*\)grupo5.*-\1grupo5/conf/AFRAINST.conf-p')
BINDIR="BINDIR"
NOVEDIR="NOVEDIR"
RECHDIR="RECHDIR"
REPODIR="REPODIR"
ACEPDIR="ACEPDIR"
PROCDIR="PROCDIR"
LOGDIR="LOGDIR"
LOGEXT=$(grep '^LOGEXT' "$CONF" | cut -d '=' -f 2)
RETORNO=""

Loguear(){
	echo "$1"
	"$BINDIR"/GRALOG.sh "AFRAINIC" "$1" "$2"
}

LeerSiONo(){
    local mensaje=$1
    while true; do
	Loguear "$mensaje" "INFO"
        read input
        
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
		Loguear "Directorio de ${tipoDir[${i}]}: ${listar[${i}]} $(ls "${listar[${i}]}") " "INFO"
	done

	local listar2=("$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$RECHDIR")
	local tipoDir2=('recepcion de archivos de llamamdas' 'Archivos de llamadas Aceptados' 'Archivos de llamadas Sospechosas' 'Archivos de Reportes de llamadas' 'Archivos Rechazados')
	
	for(( i=0;i<${#listar2[@]};i++ )); do
		Loguear "Directorio de ${tipoDir2[${i}]}: ${listar2[${i}]}" "INFO"
	done
	
	Loguear "Estado de Sistema: INICIALIZADO" "INFO"
}

verificaInstalacionCompleta(){

	MAEDIR=$(grep '^MAEDIR' "$CONF" | cut -d '=' -f 2)
	local archivos=('CdP.mae' 'CdA.mae' 'CdC.mae' 'agentes.mae' 'tllama.tab' 'umbrales.tab')
	local cant=${#archivos[@]}
	local faltantes=()
	local cF=0

	for(( i=0; i<$cant; i++ )); do
		if ! [ -f "$MAEDIR/${archivos[${i}]}" ]; then
			faltantes[${cf}]="${archivos[${i}]}"
			((cF++))
		fi
	done

	BINDIR=$(grep '^BINDIR' "$CONF" | cut -d '=' -f 2)

	local bin=('AFRAINIC.sh' 'AFRARECI' 'AFRAUMBR.sh' 'ARRANCAR.sh' 'clasificarLLamada.sh' 'DETENER.sh' 'GRALOG.sh' 'MOVERA.sh' 'parserLLamada.sh' 'validarCampos.sh' 'validarLLamada.sh' 'verificarUmbrales.sh')
	local cantBin=${#bin[@]}

	for(( j=0; j<$cantBin; j++ )); do
		if ! [ -f "$BINDIR/${bin[${j}]}" ]; then
			faltantes[${cF}]="${bin[${j}]}"
			((cF++))
		fi
	done
	
	if [ ${#faltantes[@]} -ne 0 ]; then
		Loguear "Archivos faltantes en la instalación: ${faltantes[*]}" "ERR"
		Loguear "Ejecute instalador: ./AFRAINST.sh" "ERR"
		return 1		
 	fi
	
	return 0


}

verificarPermisos(){
	BINDIR=$(grep '^BINDIR' "$CONF" | cut -d '=' -f 2)
	MAEDIR=$(grep '^MAEDIR' "$CONF" | cut -d '=' -f 2)
	
	for file in $(ls "$BINDIR"); do
		if ! [ -x "$BINDIR/$file" ]; then
			chmod +x "$BINDIR/$file"
			if [ "$?" = -1  ]; then
      				Loguear "No se pudo setear los permisos de $BINDIR/$file" "ERR"
				return 1     
    			fi
		fi			
	done

	for file in $(ls "$MAEDIR"); do
		if ! [ -r "$MAEDIR/$file" ]; then
			chmod +r "$MAEDIR/$file"
			if [ "$?" = -1  ]; then
                                Loguear "No se pudo setear los permisos de $MAEDIR/$file" "ERR"
				return 1
			fi

		fi
	done

	return 0
}		

inicializarAmbiente(){
	export GRUPO=$(grep '^GRUPO' "$CONF" | cut -d '=' -f 2)
	export CONFDIR=$(grep '^CONFDIR' "$CONF" | cut -d '=' -f 2)
	export BINDIR=$(grep '^BINDIR' "$CONF" | cut -d '=' -f 2)
	export MAEDIR=$(grep '^MAEDIR' "$CONF" | cut -d '=' -f 2)
	export DATASIZE=$(grep '^DATASIZE' "$CONF" | cut -d '=' -f 2)
	export ACEPDIR=$(grep '^ACEPDIR' "$CONF" | cut -d '=' -f 2)
	export RECHDIR=$(grep '^RECHDIR' "$CONF" | cut -d '=' -f 2)
	export PROCDIR=$(grep '^PROCDIR' "$CONF" | cut -d '=' -f 2)
	export REPODIR=$(grep '^REPODIR' "$CONF" | cut -d '=' -f 2)
	export NOVEDIR=$(grep '^NOVEDIR' "$CONF" | cut -d '=' -f 2)
	export LOGDIR=$(grep '^LOGDIR' "$CONF" | cut -d '=' -f 2)
	export LOGSIZE=$(grep '^LOGSIZE' "$CONF" | cut -d '=' -f 2)
	export LOGEXT=$(grep '^LOGEXT' "$CONF" | cut -d '=' -f 2)
	
}
	


arrancarAFRAECI(){

	LeerSiONo "¿Desea efectuar la activación de AFRARECI? Si – No"
	"$BINDIR"/GRALOG.sh "AFRAINIC" "$RETORNO" "INFO"
	
	if [ $RETORNO == "No" ]; then
		Loguear "Debe ingresar el comando ./ARRANCAR.sh AFRARECI.sh por consola." "INFO"
	else	
		pid=$(ps aux | grep "AFRARECI" | grep -v 'ARRANCAR' | grep -v 'grep' | head -n 1 | awk '{print $2}')
		
		if [ ! -z "$pid" ]; then  
			Loguear "Proceso AFRARECI ya iniciado. Debe utilizar el comando DETENER para terminarlo: ./DETENER.sh AFRARECI.sh" "WAR"
		else
			"$BINDIR"/AFRARECI &
			ID=$!
			Loguear "AFRARECI corriendo bajo el no.: $ID" "INFO"
		fi
	fi
}

Inicializar(){
	
    if [ -z "$GRUPO" ] || [  -z "$CONFDIR" ] || [ -z "$BINDIR" ] || [ -z "$MAEDIR" ] ||
		[ -z "$NOVEDIR" ] || [ -z "$ACEPDIR" ] || [ -z "$PROCDIR" ] || [ -z "$REPODIR" ]
		[ -z "$LOGDIR" ] || [ -z "$RECHDIR" ]; then
		Loguear "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente" "INFO"
        else	
		verificaInstalacionCompleta
		local completa=$?
		
		if [ "$completa" == 0 ]; then
			verificarPermisos
			local permisos=$?

			if [ "$permisos" == 0 ]; then
				inicializarAmbiente
				loguearVariables
				arrancarAFRAECI
			fi
		fi
	fi	
}
Inicializar
