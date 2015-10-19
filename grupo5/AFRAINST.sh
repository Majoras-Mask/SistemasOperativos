# Variable usada para retornar desde funciones
RETORNO=""
# Variable usada para leer entrada
input=""
# Variable GRUPO, directorio de trabajo
if [ $(echo $0| grep -c '^/.*' ) -ne 0 ] && [ $(echo $0 | grep -c 'grupo5') -eq 1 ]; then
	GRUPO=$(echo "$0" | sed -n 's-^\(.*\)grupo5.*-\1grupo5-p')
else
	GRUPO=$(echo "$PWD" | sed -n 's-^\(.*\)grupo5.*-\1grupo5-p')
fi
# Variable CONFDIR, directorio de configuracion
CONFDIR="$GRUPO/conf"
# Archivos a generar en este script
LOGFILE="AFRAINST.log"
CONFFILE="AFRAINST.conf"
# Version solicitada para perl
PERL_VERSION=5
PERL_MENSAJE_ERROR_VERSION="Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior.
Efectúe su isntalación e inténtelo nuevamente.
Proceso de Instalación Cancelado"
TERMINOS_Y_CONDICIONES="
*************************************************************
*       Proceso de Instalación de \"AFRAI-I\"				*
*   Tema I Copyright © Grupo 05 - Segundo Cuatrimestre 2015 *
*************************************************************

A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.
"
# Funcion para loguear al logfile
# Parametros
# $1 : Mensaje a loguear
# $2 : Tipo de mensaje
LoguearAlArchivo(){
	if [ ! -d "$CONFDIR" ]; then
		mkdir "$CONFDIR"
	fi
	
    local where="AFRAINST"
    local what="INFO"
    local why="$1" # mensaje
    if [ ! -z "$2" ]; then
        what="$2"
    fi
    
    local who="$USER"
    local when=$(date +"%d/%m/%y %R")
    
    echo "$when---$who---$where---$what---$why" >> "$CONFDIR/$LOGFILE" 
}

# Funcion para loguear a stdout y al logfile
# Parametros
# $1 : Mensaje a loguear
# $2 : Tipo de mensaje
Loguear(){
    echo "$1"
    LoguearAlArchivo "$1" "$2"
}

# Funcion para finalizar el programa
FinAFRAINST(){
    if [ $1 -eq 0 ]; then
        LoguearAlArchivo "Finalización de AFRAINST con exito."
        exit 0
    else
        LoguearAlArchivo "Finalización de AFRAINST con error."
        exit 1
    fi
}

# Chequea version de Perl. Si es menor a $PERL_VERSION finaliza el programa.
ChequearInstalacionPerl(){
    version=$(perl -v | sed -n 's/.*(v\([0-9]*\)\..*).*/\1/p')
    if [ $version -lt $PERL_VERSION ]; then
        Loguear "$PERL_MENSAJE_ERROR_VERSION"
        FinAFRAINST 1
    fi
    Loguear "Perl Version: $(perl -v)"
    return 0
}

# Si se encuentra el archivo .conf se asume instalacion hecha y se procede
# a verificar si está completa. Caso contrario, se chequea Perl y se instala.
VerificarInstalacion(){
    if ! [ -f "$CONFDIR/$CONFFILE" ]; then
        # No existe instalacion
        ChequearInstalacionPerl
        Loguear "$TERMINOS_Y_CONDICIONES"
        LeerSiONo "Acepta? Si - No: "
        if [ $RETORNO == "No" ]; then
            FinAFRAINST 0
        fi
        InstalarPaquete
    else
        # Instalacion encontrada
        VerificarInstalacionCompleta
    fi
    
    FinAFRAINST 0
}

# Lee de stdin y lo almacena en la variable $input. Procede a loguear la
# entrada en el logfile.
LeerInput(){
    read input
    LoguearAlArchivo "Input: $input"
    return 0
}

# Bucle para leer si o no
# Parametro:
# $1 : Mensaje a imprimir al solicitar entrada.
LeerSiONo(){
    local mensaje=$1
    while true; do
        Loguear "$mensaje"
        LeerInput
        if [ "$input" == "" ];then
			continue
        fi
        if [ "$input" = "Si" -o "$input" == "SI" -o "$input" == "si" -o "$input" == "Y"\
            -o "$input" == "y" -o "$input" == "Yes" ]; 
        then
            RETORNO="Si"
            return 0
        elif [ "$input" == "No" -o "$input" == "NO" -o "$input" == "no" \
            -o "$input" == "n" ];
        then
            RETORNO="No"
            return 0
        fi
    done
}

VerificarDirectorioReservado(){
	local directorio=$1
	local dirPrincipal=$(echo $directorio | sed -n 's-^/\?\([^/]*\).*-\1-p')
	if [ "$dirPrincipal" == "conf" ]; then
		return 1
	fi
	return 0
}

#Bucle para leer un directorio valido. Directorio valido es una cadena no
# vacia. Se le elimina el caracter / si se encuentra presente al principio
# o al final.
# Parametro:
# $1 : Mensaje a mostrar al leer el directorio.
LeerDirectorio(){
    local mensaje=$1
    while true; do
        Loguear "$mensaje"; LeerInput

        if [ -z "$input" ]; then
			RETORNO=""
			return 0
        fi
        
        local c=$(echo "$input" | grep -c "^[/0-9a-zA-Z_-]\+$")
        if [ "$c" -eq 0 ];then 
			Loguear "Introducir un directorio valido."
			continue
        fi
        
        local mensaje2
        if [ "${input:0:1}" == '/' ]; then
            mensaje2=${input:1}
        else
            mensaje2=${input}
        fi
        
        local mensaje3
        if [ "${mensaje2:(-1)}" == '/' ]; then
            local len=${#mensaje2}
            let len--
            mensaje3=${mensaje2:0:len}
        else
            mensaje3=${mensaje2}
        fi
        
        if [ -z "$mensaje3" ]; then
            Loguear "Introducir un directorio valido."
        elif [ "$( VerificarDirectorioReservado "$mensaje3"; echo $? )" -ne 0 ]; then
            Loguear "No esta permitido utilizar un directorio reservado."
        else
            RETORNO=$mensaje3
            return 0
        fi
    done
    
}


# Bucle para leer un numero.
# Parametro:
# $1 : Mensaje a mostrar al leer numero
LeerNumero(){
    local mensaje=$1
    Loguear "$mensaje";LeerInput
    if [ ${#input} -eq 0 ];then
		RETORNO=""
		return 0
    fi
    local numero=$(echo $input | grep "^[0-9]\+$")
    while [ -z "$numero" ] || [ ${#numero} -gt 15 ]; do
        Loguear "Debe ingresarse un numero valido"
        Loguear "$mensaje"; LeerInput
        if [ ${#input} -eq 0 ];then
			RETORNO=""
			return 0
		fi
        numero=$(echo $input | grep "^[0-9]\+$")
    done
    RETORNO=$numero
    return 0
}

# Bucle para leer una extension. La extension debe tener como max 5 chars.
# Parametro:
# $1 : Mensaje a mostrar al leer numero
LeerExtension(){
    local mensaje=$1
    Loguear "$mensaje"
    LeerInput
    while [ ${#input} -gt 5 ]; do
        Loguear "La extensión debe tener como máximo 5 caracteres"
        Loguear "$mensaje"
        LeerInput
    done
    RETORNO=$input
    return 0
}


# Leer el archivo conf.
# Parametro:
# $1 : variable a buscar en el archivo
# Retorno:
# Se devuelve por stdout el valor de dicha variable.
LeerArchivoConf(){
    var=$1
    valor=$(sed -n "s-^$var=\(.*\)=.*=.*-\1-p" "$CONFDIR/$CONFFILE")
    echo $valor
}


# Lee del archivo conf todas las variables de configuracion.
InicializacionConfVariables(){

    BINDIR=$(LeerArchivoConf BINDIR)
    MAEDIR=$(LeerArchivoConf MAEDIR)
    NOVEDIR=$(LeerArchivoConf NOVEDIR)
    DATASIZE=$(LeerArchivoConf DATASIZE)
    ACEPDIR=$(LeerArchivoConf ACEPDIR)
    PROCDIR=$(LeerArchivoConf PROCDIR)
    REPODIR=$(LeerArchivoConf REPODIR)
    LOGDIR=$(LeerArchivoConf LOGDIR)
    LOGEXT=$(LeerArchivoConf LOGEXT)
    LOGSIZE=$(LeerArchivoConf LOGSIZE)
    RECHDIR=$(LeerArchivoConf RECHDIR)
    
    return 0
}


# Verifica que las variables de configuracion esten inicializadas.
# Caso contrario, se establece un default.
VerificarVariables(){
    BINDIR=${BINDIR:="$GRUPO/bin"}
    MAEDIR=${MAEDIR:="$GRUPO/mae"}
    NOVEDIR=${NOVEDIR:="$GRUPO/novedades"}
    DATASIZE=${DATASIZE:="100"}
    ACEPDIR=${ACEPDIR:="$GRUPO/aceptadas"}
    PROCDIR=${PROCDIR:="$GRUPO/sospechosas"}
    REPODIR=${REPODIR:="$GRUPO/reportes"}
    LOGDIR=${LOGDIR:="$GRUPO/log"}
    LOGEXT=${LOGEXT:="log"}
    LOGSIZE=${LOGSIZE:="400"}
    RECHDIR=${RECHDIR:="$GRUPO/rechazados"}
    
    return 0
}

# Inicializa las variables de configuracion a su default
InicializacionDefaultVariables(){
    BINDIR="$GRUPO/bin"
    MAEDIR="$GRUPO/mae"
    NOVEDIR="$GRUPO/novedades"
    DATASIZE="100"
    ACEPDIR="$GRUPO/aceptadas"
    PROCDIR="$GRUPO/sospechosas"
    REPODIR="$GRUPO/reportes"
    LOGDIR="$GRUPO/log"
    LOGEXT="log"
    LOGSIZE="400"
    RECHDIR="$GRUPO/rechazados"
    
    return 0
}


# Funciones Definir. Se lee de stdin para setear la variable de configuracion
# Si se lee algo incorrecto, se setea default.
DefinirBINDIR(){
    local mensaje="Defina el directorio de instalación de los ejecutables ($BINDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ]; then
		BINDIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirMAEDIR(){
    local mensaje="Defina directorio para maestros y tablas ($MAEDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ]; then
		MAEDIR="$GRUPO/$RETORNO"
    fi
    return 0
}

DefinirNOVEDIR(){
    local mensaje="Defina el Directorio de recepción de archivos de llamadas ($NOVEDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ]; then
		NOVEDIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirDATASIZE(){
    local mensaje
    while true; do
        mensaje="Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ( $DATASIZE ): "
        LeerNumero "$mensaje"
        if [ -z "$RETORNO" ]; then
			return 0
        fi
        if [ "$RETORNO" -gt 0 ]; then
			DATASIZE=$RETORNO
            return 0
        else
            Loguear "Debe ingresar un numero mayor a cero!" "WAR"
        fi
    done
}

DefinirACEPDIR(){
    local mensaje="Defina el directorio de grabación de los archivos de llamadas aceptadas ($ACEPDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ];then
		ACEPDIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirPROCDIR(){
    local mensaje="Defina el directorio de grabación de los registros de llamadas sospechosas ($PROCDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ]; then
		PROCDIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirREPODIR(){
    local mensaje="Defina el directorio de grabación de los reportes ($REPODIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ];then
		REPODIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirLOGDIR(){
    local mensaje="Defina el directorio para los archivos de log ($LOGDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ];then
		LOGDIR="$GRUPO/$RETORNO"
	fi
    return 0
}

DefinirLOGEXT(){
    local mensaje="Defina el nombre para la extensión de lso archivos de log ( $LOGEXT ): "
    LeerExtension "$mensaje"
    if [ ! -z "$RETORNO" ];then
		LOGEXT="$RETORNO"
	fi
    return 0
}

DefinirLOGSIZE(){
    local mensaje
    while true; do
        mensaje="Defina el tamaño maximo para cada archivo de log en Kbytes ( $LOGSIZE ): "
        LeerNumero "$mensaje"
        if [ -z "$RETORNO" ]; then
			return 0
        fi
        if [ "$RETORNO" -gt 0 ]; then
			LOGSIZE=$RETORNO
            return 0
        else
            Loguear "Debe ingresar un numero mayor a cero!" "WAR"
        fi
    done
}

DefinirRECHDIR(){
    local mensaje="Defina el directorio de grabación de Archivos rechazados ($RECHDIR): "
    LeerDirectorio "$mensaje"
    if [ ! -z "$RETORNO" ]; then
		RECHDIR="$GRUPO/$RETORNO"
    fi
    return 0
}

VerificarEspacioEnDisco(){
    local espacio
    while true; do
        espacio=$(df -BM "$GRUPO" | tail -n 1 | awk '{print $4}' | sed -n 's/\([0-9]\+\)M$/\1/p')
        if [ $espacio -gt $DATASIZE ];then
            return 0
        fi
        Loguear "Insuficiente espacio en disco." "ERR"
        Loguear "Espacio disponible: $espacio Mb." "ERR"
        Loguear "Espacio requerido $DATASIZE Mb." "ERR"
        Loguear "Intentelo nuevamente." "ERR"
        #sleep '10s'
        FinAFRAINST 1
    done
    return 0
}

DefinirVariables(){
    DefinirBINDIR
    DefinirMAEDIR
    DefinirNOVEDIR
    DefinirDATASIZE
    VerificarEspacioEnDisco
    DefinirACEPDIR
    DefinirPROCDIR
    DefinirREPODIR
    DefinirLOGDIR
    DefinirLOGEXT
    DefinirLOGSIZE
    DefinirRECHDIR
    
    return 0
}

# Funcion para mostrar los valores de la variable
# Se usa cuando se le muestra al usuario el estado de la instalacion
# luego de haber ingresado los valores solicitados.
MostrarValoresVariables(){
    echo
    Loguear "Directorio de Ejecutables: $BINDIR"
    Loguear "Directorio de Maestros y Tablas: $MAEDIR"
    Loguear "Directorio de recepción de archivos de llamadas: $NOVEDIR"
    Loguear "Espacio mínimo libre para arribos: $DATASIZE Mb"
    Loguear "Directorio de Archivos de llamadas Aceptados: $ACEPDIR"
    Loguear "Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
    Loguear "Directorio de Archivos de Reportes de llamadas: $REPODIR"
    Loguear "Directorio de Archivos de Log: $LOGDIR"
    Loguear "Extensión para los archivos de log: $LOGEXT"
    Loguear "Tamaño máximo para los archivos de log: $LOGSIZE Kb"
    Loguear "Directorio de Archivos Rechazados: $RECHDIR"
    Loguear "Estado de la instalación: LISTA"
    return 0
}

# Funcion para crear directorio
# Parametros:
# $1 : nombre del directorio a crear
# Retorno:
# En caso de error, se loguea al logfile.
CrearDirectorio(){
    local directorio="$1"
    local salida
    salida=$(mkdir -p "$directorio")
    if [ $? -eq 0 ]; then
        Loguear "Directorio $directorio creado."
    else
        Loguear "No se pudo crear el directorio $directorio" "ERR"
    fi
}

# Creacion de los directorios solicitados.
CrearDirectorios(){
    Loguear "Creando Estructuras de directorio. . . ."
    CrearDirectorio "$BINDIR"
    CrearDirectorio "$MAEDIR"
    CrearDirectorio "$NOVEDIR"
    CrearDirectorio "$ACEPDIR"
    CrearDirectorio "$PROCDIR"
    CrearDirectorio "$PROCDIR/proc"
    CrearDirectorio "$REPODIR"
    CrearDirectorio "$LOGDIR"
    CrearDirectorio "$RECHDIR"
    CrearDirectorio "$RECHDIR/llamadas"
    return 0
}

# Copia los archivos de la carpeta origen a la carpeta destino.
# Parametros:
# $1: Carpeta origen.
# $2: Carpeta destino.
CopiarArchivos(){
    local origen="$1"
    local destino="$2"
    
    local files
    local files2
    
    files=$(ls "$origen" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra la carpeta origen $origen" "ERR"
        FinAFRAINST 1
    fi
    
    files2=$(ls "$destino" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra la carpeta destino $destino" "ERR"
        FinAFRAINST 1
    fi
    
    while read -r file; do
        #if [ ! -f "$destino/$file" ]; then
        #    cp "$origen/$file" "$destino"
        #fi
        if [ ! -z "$file" ];then
			cp "$origen/$file" "$destino"
        fi
    done <<< "$files"
    
    return 0
}

# Funcion que lee del paquete para ubicar los archivos a las carpetas.
MoverEjecutables(){
    Loguear "Instalando Programas y Funciones"
    CopiarArchivos "$GRUPO/AFRAINIC" "$BINDIR"
    CopiarArchivos "$GRUPO/AFRARECI" "$BINDIR"
    CopiarArchivos "$GRUPO/AFRAUMBR" "$BINDIR"
    CopiarArchivos "$GRUPO/FUNCIONES" "$BINDIR"
    CopiarArchivos "$GRUPO/AFRALIST" "$BINDIR"
    return 0
}

# Funcion que lee del paquete para ubicar los archivos a las carpetas.
MoverArchivosMaestrosYTablas(){
    Loguear "Instalando Archivos Maestros y Tablas"
    CopiarArchivos "$GRUPO/ARCHIVOS" "$MAEDIR"
    return 0
}

# Grabacion del archivo de configuracion
GrabarArchivoDeConfiguracion(){
    Loguear "Actualizando la configuración del sistema"
    echo GRUPO=$GRUPO=$USER=$(date +"%d/%m/%y %R") > "$CONFDIR/$CONFFILE"
    echo CONFDIR=$CONFDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo BINDIR=$BINDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo MAEDIR=$MAEDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo NOVEDIR=$NOVEDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo DATASIZE=$DATASIZE=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo ACEPDIR=$ACEPDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo PROCDIR=$PROCDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo REPODIR=$REPODIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo LOGDIR=$LOGDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo LOGEXT=$LOGEXT=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo LOGSIZE=$LOGSIZE=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    echo RECHDIR=$RECHDIR=$USER=$(date +"%d/%m/%y %R") >> "$CONFDIR/$CONFFILE"
    
    return 0
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
        clear
        DefinirVariables
        MostrarValoresVariables
        LeerSiONo "Desea continuar con la instalacion? ( Si - No ): "
    done
    
    LeerSiONo "Iniciando Instalación. Esta Ud. seguro? ( Si - No): "
    if [ $RETORNO == "Si" ]; then
        CargarPaquete
        Loguear "Instalación CONCLUIDA."
    else
        FinAFRAINST 0
    fi
    
    return 0
}

# Muestra el estado de los directorios, junto con sus archivos.
# En el caso de que el directorio no exista, se lo crea y se loguea.
MostrarEstadoDirectorios(){
    local files
    
    Loguear "Directorio de Configuración: $CONFDIR"
    files=$(ls "$CONFDIR" 2>&1)
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $CONFDIR instalado" "ERR"
        CrearDirectorio "$CONFDIR"
    fi
    
    Loguear "Directorio de Ejecutables: $BINDIR"
    files=$(ls "$BINDIR" 2>&1)
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $BINDIR instalado" "ERR"
        CrearDirectorio "$BINDIR"
    fi
    
    Loguear "Directorio de Maestros y Tablas: $MAEDIR"
    files=$(ls "$MAEDIR" 2>&1)
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $MAEDIR instalado" "ERR"
        CrearDirectorio "$MAEDIR"
    fi
    
    Loguear "Directorio de recepción de archivos de llamadas: $NOVEDIR"
    files=$(ls "$NOVEDIR" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $NOVEDIR" "ERR"
        CrearDirectorio "$NOVEDIR"
    fi
    
        
    Loguear "Directorio de Archivos de llamadas Aceptados: $ACEPDIR"
    files=$(ls "$ACEPDIR" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $ACEPDIR" "ERR"
        CrearDirectorio "$ACEPDIR"
    fi
    
    Loguear "Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
    files=$(ls "$PROCDIR" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $PROCDIR" "ERR"
        CrearDirectorio "$PROCDIR"
    fi
    
    Loguear "Directorio de Archivos de Reportes de llamadas: $REPODIR"
    files=$(ls "$REPODIR" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $REPODIR" "ERR"
        CrearDirectorio "$REPODIR"
    fi
    
    Loguear "Directorio de Archivos de Log: $LOGDIR"
    files=$(ls "$LOGDIR" 2>&1)
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $LOGDIR instalado" "ERR"
        CrearDirectorio "$LOGDIR"
    fi
    
    Loguear "Directorio de Archivos Rechazados: $RECHDIR"
    files=$(ls "$RECHDIR" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $RECHDIR" "ERR"
        CrearDirectorio "$RECHDIR"
    fi
    
    # Validacion para PROCDIR/proc y RECHDIR/llamadas
    files=$(ls "$RECHDIR/llamadas" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $RECHDIR/llamadas" "ERR"
        CrearDirectorio "$RECHDIR/llamadas"
    fi
    
    files=$(ls "$PROCDIR/proc" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $PROCDIR/proc" "ERR"
        CrearDirectorio "$PROCDIR/proc"
    fi
    
    return 0
}

# Obtener el estado de la instalacion
# Salida: Lista de archivos faltantes. Si no hay faltantes se devuelve cadena vacia.
VerificarEstadoInstalacion(){
    local archivos=""
    local scripts=""
    local faltantes=""
    
    archivos=$(ls "$GRUPO/ARCHIVOS" 2>&1)
    if [ ! $? -eq 0 ]; then
		Loguear "No se puede acceder a la carpeta ARCHIVOS. Reinstale el paquete original" "ERR"
    fi
                
	while read -r file; do
		if [ ! -z "$file" ] && [ ! -f "$MAEDIR/$file" ]; then
			faltantes=$(echo -e "$faltantes\n$MAEDIR/$file")
		fi
	done <<< "$archivos"
    
    scriptsAFRAINIC=$(ls -1 "$GRUPO/AFRAINIC" 2>&1)
    if [ ! $? -eq 0 ]; then
        Loguear "No se puede acceder a la carpeta AFRAINIC. Reinstale el paquete original" "ERR"
        FinAFRAINST 1
    fi
    
    scriptsAFRARECI=$(ls -1 "$GRUPO/AFRARECI" 2>&1)
    if [ ! $? -eq 0 ]; then
		Loguear "No se puede acceder a la carpeta AFRARECI. Reinstale el paquete original" "ERR"
        FinAFRAINST 1
    fi
    
    scriptsAFRAUMBR=$(ls -1 "$GRUPO/AFRAUMBR" 2>&1)
    if [ ! $? -eq 0 ]; then
		Loguear "No se puede acceder a la carpeta AFRAUMBR. Reinstale el paquete original" "ERR"
        FinAFRAINST 1
    fi
    
    scriptsFUNCIONES=$(ls -1 "$GRUPO/FUNCIONES" 2>&1)
    if [ ! $? -eq 0 ]; then
		Loguear "No se puede acceder a la carpeta FUNCIONES. Reinstale el paquete original" "ERR"
        FinAFRAINST 1
    fi
    
    scriptsAFRALIST=$(ls -1 "$GRUPO/AFRALIST" 2>&1)
    if [ ! $? -eq 0 ]; then
		Loguear "No se puede acceder a la carpeta AFRALIST. Reinstale el paquete original" "ERR"
        FinAFRAINST 1
    fi
    
    scripts="$scriptsAFRAINIC
    $scriptsAFRARECI
    $scriptsAFRAUMBR
    $scriptsFUNCIONES
    $scriptsAFRALIST"
	
	while read -r file; do
		if [ ! -z "$file" ] && [ ! -f "$BINDIR/$file" ]; then
			#faltantes="$faltantes
			#$BINDIR/$file"
			faltantes=$(echo -e "$faltantes\n$BINDIR/$file")
		fi
	done <<< "$scripts"
        
    RETORNO="$faltantes"
    return 0
}

VerificarInstalacionCompleta(){
    InicializacionConfVariables # Se lee el AFRAINST.conf
    VerificarVariables # Se establece un default en caso de variables no inicializadas
    MostrarEstadoDirectorios
    VerificarEstadoInstalacion
    if ! [ "$RETORNO" == "" ]; then
        Loguear "Estado de la instalación: Incompleta"
        Loguear "Componentes faltantes: $RETORNO"
        LeerSiONo "Desea completar la instalación? ( Si - No ): "
        if [ "$RETORNO" == "Si" ]; then
            CopiarArchivos "$GRUPO/AFRAINIC" "$BINDIR"
            CopiarArchivos "$GRUPO/AFRARECI" "$BINDIR"
            CopiarArchivos "$GRUPO/AFRAUMBR" "$BINDIR"
            CopiarArchivos "$GRUPO/AFRALIST" "$BINDIR"
            CopiarArchivos "$GRUPO/FUNCIONES" "$BINDIR"
            CopiarArchivos "$GRUPO/ARCHIVOS" "$MAEDIR"
            MostrarEstadoDirectorios
            Loguear "Estado de la instalación: Completa"
            Loguear "Proceso de Instalación Finalizado"
        fi
    else
        Loguear "Estado de la instalación: Completa"
        Loguear "Proceso de Instalación Finalizado"
    fi
    
    return 0
}

VerificarInstalacion
