# Variable usada para retornar desde funciones
RETORNO=""
# Variable usada para leer entrada
input=""
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
# Ruta de los Archivos Maestros y Tablas
RUTA_MAESTROS_Y_TABLAS="$GRUPO/.files/archivos"
# Ruta de los scripts
RUTA_SCRIPTS="$GRUPO/.files/scripts"

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
*       Proceso de Instalación de \"AFRAI-I\"                *
*   Tema I Copyright © Grupo 05 - Segundo Cuatrimestre 2015 *
*************************************************************

A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.
"

# Funcion para loguear a stdout y al logfile
# Parametros
# $1 : Mensaje a loguear
Loguear(){
    echo "$1"
    echo "$1" >> "$CONFDIR/$LOGFILE"
}

# Funcion para finalizar el programa
FinAFRAINST(){
    exit
}

# Chequea version de Perl. Si es menor a $PERL_VERSION finaliza el programa.
ChequearInstalacionPerl(){
    version=$(perl -v | sed -n 's/.*(v\([0-9]*\)\..*).*/\1/p')
    if [ $version -lt $PERL_VERSION ]; then
        Loguear "$PERL_MENSAJE_ERROR_VERSION"
        FinAFRAINST
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
            FinAFRAINST
        fi
        InstalarPaquete
    else
        # Instalacion encontrada
        VerificarInstalacionCompleta
    fi

    return 0
}

# Lee de stdin y lo almacena en la variable $input. Procede a loguear la
# entrada en el logfile.
LeerInput(){
    read input
    echo "$input" >> "$CONFDIR/$LOGFILE"
}

# Bucle para leer si o no
# Parametro:
# $1 : Mensaje a imprimir al solicitar entrada.
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


#Bucle para leer un directorio valido. Directorio valido es una cadena no
# vacia. Se le elimina el caracter / si se encuentra presente al principio
# o al final.
# Parametro:
# $1 : Mensaje a mostrar al leer el directorio.
LeerDirectorio(){
    local mensaje=$1
    while true; do
        Loguear "$mensaje"; LeerInput

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


# Bucle para leer un numero.
# Parametro:
# $1 : Mensaje a mostrar al leer numero
LeerNumero(){
    local mensaje=$1
    Loguear "$mensaje";LeerInput
    local numero=$(echo $input | grep "[0-9]\+")
    while [ -z $numero ]; do
        Loguear "Debe ingresarse un numero"
        Loguear "$mensaje"; read input; Loguear "$input"
        numero=$(echo $input | grep "[0-9]\+")
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
    while [ ${#input} -gt 6 ]; do
        Loguear "La extensión debe tener como máximo 5 caracteres"
        Loguear "$mensaje"
        read input; Loguear "$input"
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
    ACEPTDIR=$(LeerArchivoConf ACEPTDIR)
    PROCDIR=$(LeerArchivoConf PROCDIR)
    REPODIR=$(LeerArchivoConf REPODIR)
    LOGDIR=$(LeerArchivoConf LOGDIR)
    LOGEXT=$(LeerArchivoConf LOGEXT)
    LOGSIZE=$(LeerArchivoConf LOGSIZE)
    RECHDIR=$(LeerArchivoConf RECHDIR)
}


# Verifica que las variables de configuracion esten inicializadas.
# Caso contrario, se establece un default.
VerificarVariables(){
    BINDIR=${BINDIR:="bin"}
    MAEDIR=${MAEDIR:="mae"}
    NOVEDIR=${NOVEDIR:="novedades"}
    DATASIZE=${DATASIZE:="100"}
    ACEPDIR=${ACEPDIR:="aceptadas"}
    PROCDIR=${PROCDIR:="sospechosas"}
    REPODIR=${REPODIR:="reportes"}
    LOGDIR=${LOGDIR:="log"}
    LOGEXT=${LOGEXT:="log"}
    LOGSIZE=${LOGSIZE:="400"}
    RECHDIR=${RECHDIR:="rechazados"}
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


# Funciones Definir. Se lee de stdin para setear la variable de configuracion
# Si se lee algo incorrecto, se setea default.
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

# Funcion para mostrar los valores de la variable
# Se usa cuando se le muestra al usuario el estado de la instalacion
# luego de haber ingresado los valores solicitados.
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

# Funcion para crear directorio
# Parametros:
# $1 : nombre del directorio a crear
# Retorno:
# En caso de error, se loguea al logfile.
CrearDirectorio(){
    local directorio="$1"
    local salida
    salida=$(mkdir "$directorio")
    if [ $? -eq 0 ]; then
        Loguear "Directorio $directorio creado."
    else
        Loguear "No se pudo crear el directorio $directorio" "ERR"
    fi
}

# Creacion de los directorios solicitados.
CrearDirectorios(){
    Loguear "Creando Estructuras de directorio. . . ."
    CrearDirectorio "$GRUPO/$BINDIR"
    CrearDirectorio "$GRUPO/$MAEDIR"
    CrearDirectorio "$GRUPO/$NOVEDIR"
    CrearDirectorio "$GRUPO/$ACEPDIR"
    CrearDirectorio "$GRUPO/$PROCDIR"
    CrearDirectorio "$GRUPO/$PROCDIR/proc"
    CrearDirectorio "$GRUPO/$REPODIR"
    CrearDirectorio "$GRUPO/$LOGDIR"
    CrearDirectorio "$GRUPO/$RECHDIR"
    CrearDirectorio "$GRUPO/$RECHDIR/llamadas"
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
        return 1
    fi
    
    files2=$(ls "$destino" 2>&1)
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra la carpeta destino $destino" "ERR"
        return 1
    fi
    
    while read -r file; do
        cp "$origen/$file" "$destino"
    done <<< "$files"

}

# Funcion que lee del paquete para ubicar los archivos a las carpetas.
MoverEjecutables(){
    Loguear "Instalando Programas y Funciones"
    CopiarArchivos "$RUTA_SCRIPTS" "$GRUPO/$BINDIR"
}

# Funcion que lee del paquete para ubicar los archivos a las carpetas.
MoverArchivosMaestrosYTablas(){
    Loguear "Instalando Archivos Maestros y Tablas"
    CopiarArchivos "$RUTA_MAESTROS_Y_TABLAS" "$GRUPO/$MAEDIR"
}

# Grabacion del archivo de configuracion
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

# Muestra el estado de los directorios, junto con sus archivos.
# En el caso de que el directorio no exista, se lo crea y se loguea.
MostrarEstadoDirectorios(){
    local files
    
    Loguear "Directorio de Configuración: $CONFDIR"
    files=$(ls "$CONFDIR")
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $GRUPO/$CONFDIR instalado" "ERR"
        CrearDirectorio "$GRUPO/$CONFDIR"
    fi
    
    Loguear "Directorio de Ejecutables: $GRUPO/$BINDIR"
    files=$(ls "$GRUPO/$BINDIR")
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $GRUPO/$BINDIR instalado" "ERR"
        CrearDirectorio "$GRUPO/$BINDIR"
    fi
    
    Loguear "Directorio de Maestros y Tablas: $GRUPO/$MAEDIR"
    files=$(ls "$GRUPO/$MAEDIR")
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $GRUPO/$MAEDIR instalado" "ERR"
        CrearDirectorio "$GRUPO/$MAEDIR"
    fi
    
    Loguear "Directorio de recepción de archivos de llamadas: $GRUPO/$NOVEDIR"
    files=$(ls "$GRUPO/$NOVEDIR")
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $GRUPO/$NOVEDIR" "ERR"
        CrearDirectorio "$GRUPO/$NOVEDIR"
    fi
    
        
    Loguear "Directorio de Archivos de llamadas Aceptados: $GRUPO/$ACEPDIR"
    files=$(ls "$GRUPO/$ACEPDIR")
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $GRUPO/$ACEPDIR" "ERR"
        CrearDirectorio "$GRUPO/$ACEPDIR"
    fi
    
    Loguear "Directorio de Archivos de llamadas Sospechosas: $GRUPO/$PROCDIR"
    files=$(ls "$GRUPO/$PROCDIR")
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $GRUPO/$PROCDIR" "ERR"
        CrearDirectorio "$GRUPO/$PROCDIR"
    fi
    
    Loguear "Directorio de Archivos de Reportes de llamadas: $GRUPO/$REPODIR"
    files=$(ls "$GRUPO/$REPODIR")
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $GRUPO/$REPODIR" "ERR"
        CrearDirectorio "$GRUPO/$REPODIR"
    fi
    
    Loguear "Directorio de Archivos de Log: $GRUPO/$LOGDIR"
    files=$(ls "$GRUPO/$LOGDIR")
    if [ $? -eq 0 ]; then
        Loguear "$files"
    else
        Loguear "No se encuentra el directorio $GRUPO/$LOGDIR instalado" "ERR"
        CrearDirectorio "$GRUPO/$LOGDIR"
    fi
    
    Loguear "Directorio de Archivos Rechazados: $GRUPO/$RECHDIR"
    files=$(ls "$GRUPO/$RECHDIR")
    if ! [ $? -eq 0 ]; then
        Loguear "No se encuentra el directorio $GRUPO/$RECHDIR" "ERR"
        CrearDirectorio "$GRUPO/$RECHDIR"
    fi
}

# Obtener el estado de la instalacion
# Salida: Lista de archivos faltantes. Si no hay faltantes se devuelve cadena vacia.
VerificarEstadoInstalacion(){
    local archivos=""
    local scripts=""
    local faltantes=""
    
    archivos=$(ls "$RUTA_MAESTROS_Y_TABLAS" 2>&1)
    while read -r file; do
        if ! [ -f "$GRUPO/$MAEDIR/$file" ]; then
            faltantes="$faltantes$GRUPO/$MAEDIR/$file
            "
        fi
    done <<< "$archivos"
    
    scripts=$(ls "$RUTA_SCRIPTS" 2>&1)
    while read -r file; do
        if ! [ -f "$GRUPO/$BINDIR/$file" ]; then
            faltantes="$faltantes$GRUPO/$BINDIR/$file
            "
        fi
    done <<< "$scripts"
    
    RETORNO="$faltantes"
}

VerificarInstalacionCompleta(){
    InicializacionConfVariables
    VerificarVariables
    # Hacer verificacion que existe la carpeta RUTA_SCRIPTS Y RUTA_MAESTROS
    MostrarEstadoDirectorios
    VerificarEstadoInstalacion
    if ! [ "$RETORNO" == "" ]; then
        Loguear "Estado de la instalación: Incompleta"
        Loguear "Componentes faltantes: $RETORNO"
        LeerSiONo "Desea completar la instalación? ( Si - No ): "
        if [ "$RETORNO" = "Si" ]; then
            CopiarArchivos "$RUTA_SCRIPTS" "$GRUPO/$BINDIR"
            CopiarArchivos "$RUTA_MAESTROS_Y_TABLAS" "$GRUPO/$MAEDIR"
        fi
    else
        Loguear "Estado de la instalación: Completa"
    fi
}

VerificarInstalacion
