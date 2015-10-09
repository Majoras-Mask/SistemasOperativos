#!/bin/bash
#**********************************************************************
#Comand : AFRARECI
#**********************************************************************
#VARIBLES DE ENTORNO
#NOVEDIR
#ACEPDIR
#MAEDIR
#RECHDIR
#LOGDIR
#INICIALIZADO

#VARIBLES CONFIGURABLES
export TESPERA=2
export CANLOOP="TRUE"
export TRUE=1
export FALSE=0

#******************************************************************
# Chequeo si se inicializó el ambiente desde el -comando AFRAINIC-
#*****************************************************************
checkAmbienteInicializado(){
	if [ -z "$BINDIR" ] || [ -z "$MAEDIR" ] || [ -z "$NOVEDIR" ] || [ -z "$ACEPDIR" ] || [ -z "$RECHDIR" ]; then
		return $FALSE
	else
		return $TRUE
	fi
}

#********************************************************************
# Chequea si hay nuevos archivos para analizar en NOVEDIR
#********************************************************************
checkNuevosArchivosNovedades() {
	#Eliminamos directorios
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for DIRECTORIO in $( ls "$NOVEDIR" -F | grep "/$" )
	do
		DIRECTORIO=`echo $DIRECTORIO | sed "s-/--"`
		mv "$NOVEDIR/$DIRECTORIO" "$RECHDIR"
	done
	
	#Cuenta los archivos solo en NOVEDIR sin entrar en subDirectorios
	local cant_archivos=`find "$1" -maxdepth 1 -type f | wc --lines`			
	if [ "$cant_archivos" != 0 ]	
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Cantidad de archivos nuevos en $NOVEDIR: $cant_archivos" "INFO"		
		return $TRUE 
	else
		return $FALSE
	fi
}

#********************************************************************
# Chequea si hay nuevos archivos para protocolizar en ACEPTDIR 
#********************************************************************
checkNuevosArchivosAceptados(){
	#Cuenta los archivos en ACEPDIR 
	local cant_archivos=`find "$1" -type f | wc --lines`
	if [ "$cant_archivos" -gt 0 ]	
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Cantidad de archivos nuevos en $ACEPDIR: $cant_archivos" "INFO"			
		return $TRUE 
	else
		return $FALSE
	fi
}

#*********************************************************************
# Valida el formato de nombre del archivo 
#*********************************************************************
checkFormatoNombreArchivo(){
	#chequeamos que tenga todos los separadores

	cantidadGuiones=`echo $1 | grep -o '_' | wc -w`	
	if [ $cantidadGuiones == 1 ]
	then
	   	#recortamos del nombre del file todas las secciones	
		central=`echo $1 | cut -d"_" -f1`
		fecha=`echo $1 | cut -d"_" -f2`
           
		#Si alguno es vacio, no tiene los campos completos		
		if [ -z "$central" -o -z "$fecha" ]
		then
			"$BINDIR"/GRALOG.sh "AFRARECI" "Formato de nombre de archivo incompleto" "INFO"
			return $FALSE
		
		else
			"$BINDIR"/GRALOG.sh "AFRARECI" "Formato de nombre de archivo completo" "INFO"
			return $TRUE 
		fi
	else
		#No tiene la cantidad de separadores correctos
		"$BINDIR"/GRALOG.sh "AFRARECI" "Formato de nombre de archivo invalido" "INFO"		
		return $FALSE
	fi
}
#*********************************************************************
# Valida central del archivo 
#*********************************************************************
checkCentral(){	
	centralActual=$1
	TESTCENTRAL=`grep "^$centralActual;.*" $MAEDIR/CdC.mae | cut -d";" -f1`
	if [ "$centralActual" != "$TESTCENTRAL" ]
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Central invalida $TESTCENTRAL" "INFO"
		return $FALSE
	else	
		"$BINDIR"/GRALOG.sh "AFRARECI" "Central valida $TESTCENTRAL" "INFO"
		return $TRUE
	fi		
}

#*********************************************************************
# Validar extension de archivo
#*********************************************************************
checkExtension(){
	archivo=$1
	local arch=`echo $1 | grep -i '\.'`
	if [ -n "$arch" ] ; 
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Extension $arch invalida" "INFO"
		return $FALSE
		
	else
		"$BINDIR"/GRALOG.sh "AFRARECI" "Extension valida" "INFO"
		return $TRUE
	fi
}

#*********************************************************************
# Valida si el año ingresado es bisiesto 
#*********************************************************************
checkAnioBisiesto(){
	anio=$1

	if [ $[ $anio % 4 ] -eq 0 ] ; 
	then
		if [ $[ $anio % 100 ] -ne 0  -o $[ $anio % 400 ] -eq 0 ] ;
		then
			return $TRUE
		fi
	else
		return $FALSE
	fi
}

#*********************************************************************
# Valida si los dias se corresponden con el mes 
#*********************************************************************
checkDiasMes(){
	dia=`echo $1 | cut -d"-" -f1`
	mes=`echo $1 | cut -d"-" -f2`
	anio=`echo $1 | cut -d"-" -f3`
	
	checkAnioBisiesto $anio
	esBisiesto=$?

	if [ "$mes" = "04" -o "$mes" = "06" -o "$mes" = "09" -o "$mes" = "11" ]
	then
		if [ $dia -le 30 ] 
		then 
			return $TRUE
		else
			return $FALSE
		fi
	else
		if [ "$mes" = "01" -o "$mes" = "03" -o "$mes" = "05" -o "$mes" = "07" -o "$mes" = "08" -o "$mes" = "10" -o "$mes" = "12" ]
		then
			if [ $dia -le 31 ] 
			then 
				return $TRUE
			else
				return $FALSE
			fi
		else

			if [ "$mes" == "02" -a "$esBisiesto" == "$TRUE" ]
			then
				if [ $dia -le 29 ]
				then 
					return $TRUE
				else
					return $FALSE
				fi
			else
			
				if [ $dia -le 28 ]
				then 
					return $TRUE
				else
					return $FALSE
				fi
			fi
		fi
	fi
}

#*********************************************************************
# Valida fecha del archivo 
#*********************************************************************
checkFecha(){
	dia=`echo $1 | cut -d"-" -f1`
	mes=`echo $1 | cut -d"-" -f2`
	anio=`echo $1 | cut -d"-" -f3`
	testDia=`echo $dia | grep "^[0][1-9]\|^[1-2][0-9]\|^[3][0-1]"`
	testMes=`echo $mes | grep "^[0][1-9]\|[1][0-2]"`
	testAnio=`echo $anio | grep "^[0-9][0-9][0-9][0-9]"`

	if [ -z "$testDia" -o -z "$testMes" -o -z "$testAnio" ]
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Fecha de formato invalida " "INFO"
		return $FALSE
	else
		checkDiasMes $1
		esFechaValida=$?
		
		if [ "$esFechaValida" = "$TRUE" ]
		then 	
			"$BINDIR"/GRALOG.sh "AFRARECI" "Fecha de valida" "INFO"
			return $TRUE	
		else
			"$BINDIR"/GRALOG.sh "AFRARECI" "Fecha de invalida " "INFO"
			return $FALSE
		fi
	fi
}

#*********************************************************************
# Valida el nombre completo del archivo 
#*********************************************************************
#$1= nombre completo del archivo
checkNombreCompletoArchivo(){	
	central=`echo $1 | cut -d"_" -f1`
	checkCentral $central
	RESULCENTRAL=$?
			
#	fecha=`echo $1 | cut -d"_" -f5 | cut -d"." -f1`
#	checkFecha $fecha
#	RESULFECHA=$?
#	if [ $RESULCENTRAL == 1 -a $RESULFECHA == 1 ];
	if [ $RESULCENTRAL == 1 ];
		then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Nombre de archivo valido" "INFO"
		return $TRUE
	else
		"$BINDIR"/GRALOG.sh "AFRARECI" "Nombre de archivo invalido" "INFO"
		return $FALSE
	fi
}

#*********************************************************************
# Valida el tipo, formato de nombre y nombre del archivo 
#*********************************************************************
checkArchivos(){
	#Establecemos el ESPACIO como separador entre archivos
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	for ARCHIVO in $( ls "$NOVEDIR" -F | grep -v / )
	do
		checkFormatoNombreArchivo "$ARCHIVO"
		RESULFORMATONOMBREARCH=$?
		
		checkNombreCompletoArchivo "$ARCHIVO"
		RESULNOMBREARCHIVO=$?
		
		checkExtension "$ARCHIVO"
		RESULEXTENSIONARCHIVO=$?

		if [ $RESULFORMATONOMBREARCH == 1 -a $RESULNOMBREARCHIVO == 1 -a $RESULEXTENSIONARCHIVO == 1 ];
		then
										
			"$BINDIR"/MOVERA.sh "$NOVEDIR/$ARCHIVO" "$ACEPDIR" "AFRARECI"
			"$BINDIR"/GRALOG.sh "AFRARECI" "Archivo valido movido: $ARCHIVO" "INFO"

		else
			"$BINDIR"/MOVERA.sh "$NOVEDIR/$ARCHIVO" "$RECHDIR" "AFRARECI"
			"$BINDIR"/GRALOG.sh "AFRARECI" "Archivo invalido movido: $ARCHIVO" "INFO" 
		fi
	done	
}

#**********************************************************************
# Bucle eje del demonio
#**********************************************************************
ejecutar(){
	i=0
	"$BINDIR"/GRALOG.sh "AFRARECI" "Comienzo de Ejecucion" "INFO"
	 
	while [ "$CANLOOP" = "TRUE" ]
	do
		checkNuevosArchivosNovedades "$NOVEDIR"
		EXISTENOVEDAD=$?
		if [ $EXISTENOVEDAD -eq $TRUE ]
		then
			"$BINDIR"/GRALOG.sh "AFRARECI" "Archivos a validar encontrados en novedades" "INFO"
			checkArchivos "$NOVEDIR"
		else
			checkNuevosArchivosAceptados "$ACEPDIR"
			EXISTEACEPT=$?
			if [ $EXISTEACEPT -eq $TRUE ]
			then
				#verifico que el proceso AFRAUMBR no este en ejecucion
				local salida=$("$BINDIR"/ARRANCAR.sh "AFRAUMBR.sh")
				if [ $? -eq 0 ]; then
					"$BINDIR"/GRALOG.sh "AFRARECI" "Inicio ejecucion del proceso AFRAUMBR" "INFO"
					"$BINDIR"/GRALOG.sh "AFRARECI" "AFRAUMBR corriendo bajo el no.: $salida"
				else
					"$BINDIR"/GRALOG.sh "AFRARECI" "Invocación de AFRAUMBR pospuesta para el siguiente ciclo."
				fi
				
				#PROCESO=`ps | grep -c "AFRAUMBR" | grep -v "ARRANCAR"`
				#if [ "$PROCESO" = "0" ]
				#then
			    #  		"$BINDIR"/GRALOG.sh "AFRARECI" "Archivos a protocolizar encontrados en aceptados" "INFO"
			    #  		"$BINDIR"/GRALOG.sh "AFRARECI" "Inicio ejecucion del proceso AFRAUMBR" "INFO"
			    #  		#"$BINDIR"/ARRANCAR.sh "AFRAUMBR.sh"
			    #  		#"$BINDIR"/ARRANCAR.sh "dormir.sh"
				#fi	
					
			fi
		fi
		i=`expr $i + 1`
		"$BINDIR"/GRALOG.sh "AFRARECI" "Fin ciclo Nro:"$i "INFO"
		sleep $TESPERA
	done
	"$BINDIR"/GRALOG.sh "AFRARECI" "Fin de Ejecucion AFRARECI" "INFO"
}
#**********************************************************************
# PRINCIPAL
#**********************************************************************

"$BINDIR"/GRALOG.sh "AFRARECI" "Inicio AFRARECI" "INFO"
checkAmbienteInicializado
	if [ $? -eq $TRUE ];
	then
		"$BINDIR"/GRALOG.sh "AFRARECI" "Ambiente  inicializado" "INFO"		
		ejecutar
	else
		"$BINDIR"/GRALOG.sh "AFRARECI" "Ambiente no inicializado" "ERR"
		exit 0
	fi