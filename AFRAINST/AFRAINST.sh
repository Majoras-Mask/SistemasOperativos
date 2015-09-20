# Variable usada para retornar desde funciones
RETORNO=""
# Variables del sistema
VARIABLES="GRUPO CONFDIR BINDIR MAEDIR DATASIZE ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGSIZE"
# Variable GRUPO, directorio de trabajo
GRUPO="$PWD"
# Variable CONFDIR, directorio de configuracion
CONFDIR="$PWD/conf"
# Archivos a generar en este script
LOGFILE="AFRAINST.log"
CONFFILE="AFRAINST.conf"
# Archivos a chequear
# Archivos Maestros y Tablas
FILES_MAEDIR="CdP.mae CdA.mae agentes.mae tllama.tab umbral.tab"
# Archivos de scripts
FILES_SCRIPTS=""
# Comandos a utilizar
GRALOG="Loguear" # Comando para logear.
# Version solicitada para perl
PERL_VERSION=5
PERL_MENSAJE_ERROR_VERSION="Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior.
Efectúe su isntalación e inténtelo nuevamente.
Proceso de Instalación Cancelado"
TERMINOS_Y_CONDICIONES="
*************************************************************
*		Proceso de Instalación de \"AFRAI-I\"				 *
*   Tema I Copyright © Grupo 05 - Segundo Cuatrimestre 2015 *
*************************************************************

A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.
"

Loguear(){
    echo "$1"
    echo "$1" >> "$CONFDIR/$LOGFILE"
}

FinAFRAINST(){
	exit
}

ChequearInstalacionPerl(){
    version=$(perl -v | sed -n 's/.*(v\([0-9]*\)\..*).*/\1/p')
    if [ $version -lt $PERL_VERSION ]; then
        Loguear "$PERL_MENSAJE_ERROR_VERSION"
        FinAFRAINST
    fi
    
    Loguear "Perl Version: $(perl -v)"

    return 0
}

VerificarInstalacion(){
    if ! [ -f "$CONFDIR/$CONFFILE" ]; then
        # No existe instalacion
        ChequearInstalacionPerl
        Loguear "$TERMINOS_Y_CONDICIONES"
        LeerSiONo "Acepta? Si - No: "
        if [ $RETORNO == "No" ]; then
			FinAFRAINST
		fi
        InstalarPaquete
    else
        # Instalacion encontrada
        VerificarInstalacionCompleta
    fi

    return 0
}

LeerSiONo(){
    local mensaje=$1
    while true; do
        Loguear "$mensaje" 
        read input
        Loguear "$input"
        
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

LeerArchivoConf(){
    var=$1
    valor=$(sed -n "s-^$var=\(.*\)=.*=.*-\1-p" "$CONFDIR/$CONFFILE")
    echo $valor
}

InicializacionConfVariables(){
	BINDIR=$(LeerArchivoConf BINDIR)
	MAEDIR=$(LeerArchivoConf MAEDIR)
	NOVEDIR=$(LeerArchivoConf NOVEDIR)
	DATASIZE=$(LeerArchivoConf DATASIZE)
	ACEPTDIR=$(LeerArchivoConf ACEPTDIR)
	PROCDIR=$(LeerArchivoConf PROCDIR)
	REPODIR=$(LeerArchivoConf REPODIR)
	LOGDIR=$(LeerArchivoConf LOGDIR)
	LOGEXT=$(LeerArchivoConf LOGEXT)
	LOGSIZE=$(LeerArchivoConf LOGSIZE)
	RECHDIR=$(LeerArchivoConf RECHDIR)
}

InicializacionVariables(){
    BINDIR=${BINDIR:="bin"}
    MAEDIR=${MAEDIR:="mae"}
    NOVEDIR=${NOVEDIR:="novedades"}
    DATASIZE=${DATASIZE:="100"}
    ACEPDIR=${ACEPDIR:"aceptadas"}
    PROCDIR=${PROCDIR:"sospechosas"}
    REPODIR=${REPODIR:"reportes"}
    LOGDIR=${LOGDIR:"log"}
    LOGEXT=${LOGEXT:"log"}
    LOGSIZE=${LOGSIZE:"400"}
    RECHDIR=${RECHDIR:"rechazados"}
}

# Inicializa las variables de configuracion a su default
InicializacionDefaultVariables(){
    BINDIR="bin"
    MAEDIR="mae"
    NOVEDIR="novedades"
    DATASIZE="100"
    ACEPDIR="aceptadas"
    PROCDIR="sospechosas"
    REPODIR="reportes"
    LOGDIR="log"
    LOGEXT="log"
    LOGSIZE="400"
    RECHDIR="rechazados"
}

VerificarInstalacionCompleta(){
    echo    
}

LeerDirectorio(){
	local mensaje=$1
	while true; do
		Loguear "$mensaje"; read input
		Loguear "$input"
		if [ -z $input ]; then
			Loguear "Introducir un directorio valido."
			continue
		fi
		
		local mensaje2
		if [ ${input:0:1} == '/' ]; then
			mensaje2=${input:1}
		else
			mensaje2=${input}
		fi
		
		local mensaje3
		if [ ${mensaje2:(-1)} == '/' ]; then
			len=${#mensaje2}
			let len--
			mensaje3=${mensaje2:0:len}
		else
			mensaje3=${mensaje2}
		fi
		
		if [ -z $mensaje3 ]; then
			Loguear "Introducir un directorio valido."
		else
			RETORNO=$mensaje3
			return 0
		fi
	done
	
}

LeerNumero(){
	local mensaje=$1
	Loguear "$mensaje";read input; Loguear "$input"
	local numero=$(echo $input | grep "[0-9]\+")
	while [ -z $numero ]; do
		Loguear "Debe ingresarse un numero"
		Loguear "$mensaje"; read input; Loguear "$input"
		numero=$(echo $input | grep "[0-9]\+")
	done
	RETORNO=$numero
	return 0
}

LeerExtension(){
	local mensaje=$1
	Loguear "$mensaje"
	read input; Loguear "$input"
	while [ ${#input} -gt 6 ]; do
		Loguear "La extensión debe tener como máximo 5 caracteres"
		Loguear "$mensaje"
		read input; Loguear "$input"
	done
	RETORNO=$input
	return 0
}

DefinirBINDIR(){
	mensaje="Defina el directorio de instalación de los ejecutables ($GRUPO/$BINDIR): "
	LeerDirectorio "$mensaje"
	BINDIR=${RETORNO:="bin"}
}

DefinirMAEDIR(){
    mensaje="Defina directorio para maestros y tablas ($GRUPO/$MAEDIR): "
	LeerDirectorio "$mensaje"
	MAEDIR=${RETORNO:="mae"}
}

DefinirNOVEDIR(){
	mensaje="Defina el Directorio de recepción de archivos de llamadas ($GRUPO/$NOVEDIR): "
	LeerDirectorio "$mensaje"
	NOVEDIR=${RETORNO:="novedades"}
}

DefinirDATASIZE(){
	mensaje="Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ( $DATASIZE ): "
	LeerNumero "$mensaje"
	DATASIZE=${RETORNO:="100"}
	
}

DefinirACEPDIR(){
	mensaje="Defina el directorio de grabación de los archivos de llamadas aceptadas ($GRUPO/$ACEPDIR): "
	LeerDirectorio "$mensaje"
	ACEPDIR=${RETORNO:="aceptadas"}
}

DefinirPROCDIR(){
	mensaje="Defina el directorio de grabación del os registros de llamadas sospechosas ($GRUPO/$PROCDIR): "
	LeerDirectorio "$mensaje"
	PROCDIR=${RETORNO:="sospechosas"}
}

DefinirREPODIR(){
	mensaje="Defina el directorio de grabación de los reportes ($GRUPO/$REPODIR): "
	LeerDirectorio "$mensaje"
	REPODIR=${RETORNO:="reportes"}
}

DefinirLOGDIR(){
	mensaje="Defina el directorio para los archivos de log ($GRUPO/$LOGDIR): "
	LeerDirectorio "$mensaje"
	LOGDIR=${RETORNO:="log"}
}

DefinirLOGEXT(){
	mensaje="Defina el nombre para la extensión de lso archivos de log ( $LOGEXT ): "
	LeerExtension "$mensaje"
	LOGEXT=${RETORNO:="log"}
}

DefinirLOGSIZE(){
	mensaje="Defina el tamaño maximo para cada archivo de log en Kbytes ( $LOGSIZE ): "
	LeerNumero "$mensaje"
	LOGSIZE=${RETORNO:="400"}
}

DefinirRECHDIR(){
	mensaje="Defina el directorio de grabación de Archivos rechazados ($GRUPO/$RECHDIR): "
	LeerDirectorio "$mensaje"
	RECHDIR=${RETORNO:="rechazadas"}
}

DefinirVariables(){
	DefinirBINDIR
	DefinirMAEDIR
	DefinirNOVEDIR
	DefinirDATASIZE
	DefinirACEPDIR
	DefinirPROCDIR
	DefinirREPODIR
	DefinirLOGDIR
	DefinirLOGEXT
	DefinirLOGSIZE
	DefinirRECHDIR	
}

MostrarValoresVariables(){
	Loguear "Directorio de Ejecutables: $GRUPO/$BINDIR"
	Loguear "Directorio de Maestros y Tablas: $GRUPO/$MAEDIR"
	Loguear "Directorio de recepción de archivos de llamadas: $GRUPO/$NOVEDIR"
	Loguear "Espacio mínimo libre para arribos: $DATASIZE Mb"
	Loguear "Directorio de Archivos de llamadas Aceptados: $GRUPO/$ACEPDIR"
	Loguear "Directorio de Archivos de llamadas Sospechosas: $GRUPO/$PROCDIR"
	Loguear "Directorio de Archivos de Reportes de llamadas: $GRUPO/$REPODIR"
	Loguear "Directorio de Archivos de Log: $GRUPO/$LOGDIR"
	Loguear "Extensión para los archivos de log: $LOGEXT"
	Loguear "Tamaño máximo para los archivos de log: $LOGSIZE Kb"
	Loguear "Directorio de Archivos Rechazados: $GRUPO/$RECHDIR"
	Loguear "Estado de la instalación: LISTA"
}

CrearDirectorios(){
	Loguear "Creando Estructuras de directorio. . . ."
	mkdir "$GRUPO/$BINDIR"
	mkdir "$GRUPO/$MAEDIR"
	mkdir "$GRUPO/$NOVEDIR"
	mkdir "$GRUPO/$ACEPDIR"
	mkdir "$GRUPO/$PROCDIR"
	mkdir "$GRUPO/$PROCDIR/proc"
	mkdir "$GRUPO/$REPODIR"
	mkdir "$GRUPO/$LOGDIR"
	mkdir "$GRUPO/$RECHDIR"
	mkdir "$GRUPO/$RECHDIR/llamadas"
}

MoverEjecutables(){
	Loguear "Instalando Programas y Funciones"
}

MoverArchivosMaestrosYTablas(){
	Loguear "Instalando Archivos Maestros y Tablas"
}

GrabarArchivoDeConfiguracion(){
	Loguear "Actualizando la configuración del sistema"
	echo GRUPO=$GRUPO=$USERNAME=$(date +"%d/%m/%y %R") > "$CONFDIR/$CONFFILE"
	echo CONFDIR=$CONFDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo BINDIR=$BINDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo MAEDIR=$MAEDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo NOVEDIR=$NOVEDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo DATASIZE=$DATASIZE=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo ACEPDIR=$ACEPDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo PROCDIR=$PROCDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo REPODIR=$REPODIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo LOGDIR=$LOGDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo LOGEXT=$LOGEXT=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo LOGSIZE=$LOGSIZE=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	echo RECHDIR=$RECHDIR=$USERNAME=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
	
}

CargarPaquete(){
	CrearDirectorios
	MoverEjecutables
	MoverArchivosMaestrosYTablas
	GrabarArchivoDeConfiguracion
}

InstalarPaquete(){
	InicializacionDefaultVariables
	DefinirVariables
	MostrarValoresVariables
	LeerSiONo "Desea continuar con la instalacion? ( Si - No ): "
	while [ $RETORNO == "No" ]; do
		DefinirVariables
		MostrarValoresVariables
		LeerSiONo "Desea continuar con la instalacion? ( Si - No ): "
	done
	
	LeerSiONo "Iniciando Instalación. Esta Ud. seguro? ( Si - No): "
	if [ $RETORNO == "Si" ]; then
		CargarPaquete
	else
		FinAFRAINST
	fi
}


VerificarInstalacion

