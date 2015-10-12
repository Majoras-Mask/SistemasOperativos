#!/Bin/bash
source "$BINDIR/"clasificarLLamada.sh
source "$BINDIR/"parserLLamada.sh
UMBRALES="$MAEDIR/umbrales.tab"
ACTIVO="Activo"
INACTIVO="Inactivo"
verificarUmbralYgrabarLLamadaSospechosa()
{
	local registroLLamada="$1"
	local tipoLLamada="$2"
	local idCentral="$3"
	anioMesDia="$4"
	echo "aniodmesdia = $anioMesDia"
	#echo "tipoLLamada = $tipoLLamada"
	local idAgente
	local fechaYHora
	local numeroAreaA
	local numeroLineaA
	local numeroPaisB
	local numeroAreaB
	local numeroLineaB
	local tiempoConversacion
	parsearLLamada "$registroLLamada" idAgente fechaYHora numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
	local linea
	local cont=0
	while read linea || [ -n "$linea" ]
	do
		cont=`expr $cont + 1`
		match1=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroAreaB;[0-9]*;[A-Z][a-z]*//")
		match3=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroPaisB;[0-9]*;[A-Z][a-z]*//")
		match2=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroAreaB;[0-9]*;[0-9]*;[A-Z][a-z]*//")
		#echo "match = $match"
		if [ "$match1" == "" ] || [ "$match2" == "" ] || [ "$match3" == "" ] 
		then
			if [ "$match1" == "" ]
				then
				verificarUmbral "$linea" "$tiempoConversacion" 
				local res="$?"
				if [ "$res" -ne  0 ]
					then
					if [ "$res" -eq 2 ]
						then
						idUmbral=$(echo $linea | awk -F';' '{ print $1 }')
						echo " logueando "
						echo " $idUmbral "
						echo " $idCentral"
						echo "  $idAgente"
						echo " $tipoLLamada"
						echo " $fechaYHora"
						echo " $tiempoConversacion"
						echo " $numeroAreaA"
						echo " $numeroLineaA"
						echo " $numeroPaisB"
						echo " $numeroAreaB"
						echo " $numeroLineaB"
						echo " $aniodMesDia"
						grabarLLamadaSospechosa "$registroLLamada" "$idUmbral" "$anioMesDia"
					fi
					return "$res"
				fi
			else
				if [ "$match3" == "" ]
				then
					verificarUmbral "$linea" "$tiempoConversacion" 
					local res="$?"
					if [ "$res" -ne   0 ]
						then	
						if [ "$res" -eq 2 ]
							then
							idUmbral=$(echo $linea | awk -F';' '{ print $1 }')
							grabarLLamadaSospechosa "$registroLLamada" "$idUmbral" "$anioMesDia"
						fi
					fi
					return "$res"
				else
					verificarUmbralConMasDeUno "$linea" "$tiempoConversacion" 
					local res="$?"
					if [ "$res" -ne  0 ]
						then
						if [ "$res" -eq 2]
							then
							idUmbral=$(echo $linea | awk -F';' '{ print $1 }')
							grabarLLamadaSospechosa "$registroLLamada" "$idUmbral" "$anioMesDia"
						fi
					fi
					return "$res"
				fi
				return "$res"
			fi	
		fi
	done < "$UMBRALES"
	return 0
}

maximoUmbral()
{
	local umb1=`expr $1`
	local umb2=`expr $2`
	if [ "$umb1" -gt "$umb2" ]
		then
		return `expr $umb1`
	fi
	return `expr $umb2` 
}


verificarUmbralConMasDeUno() {
	local linea="$1"
	local tiempoConversacion="$2"
	local umbralActivo=$( echo "$linea" | awk -F';' '{print $8 }')
	case "$umbralActivo" in
	"$ACTIVO")
		#echo $linea
		conUmbral=`expr $conUmbral + 1`
		local umbral1=$( echo $linea | awk -F';' '{ print $6 }')
		local umbral2=$( echo $linea | awk -F';' '{ print $7 }')
		echo "umbral1 = $umbral1"
		echo "tiempoConversacion = $tiempoConversacion"
		umbral1=`expr $umbral1`
		umbral2=`expr $umbral2`
		maximoUmbral "$umbral1" "$umbral2" 
		maximo="$?"
		tiempoConversacion=`expr $tiempoConversacion`
		if [ "$tiempoConversacion" -gt "$maximo" ]
		then
			return 2
		fi
		return 1
	;;
	"$INACTIVO")
		sinUmbral=`expr $sinUmbral + 1`
		echo "sin umbral"
		return 0
		;;
	esac
}
verificarUmbral() {
	local linea="$1"
	local tiempoConversacion="$2"
	local umbralActivo=$( echo "$linea" | awk -F';' '{print $7 }')
	case "$umbralActivo" in
	"$ACTIVO")
		#echo $linea
		conUmbral=`expr $conUmbral + 1`
		local umbral1=$( echo $linea | awk -F';' '{ print $6 }')
		echo "umbral1 = $umbral1"
		echo "tiempoConversacion = $tiempoConversacion"
		umbral1=`expr $umbral1`	
		tiempoConversacion=`expr $tiempoConversacion`
		if [ "$tiempoConversacion" -gt "$umbral1" ]
		then
			return 2
		fi
		return 1
		;;
	"$INACTIVO")
		echo "sin umbral"
	return 0
	;;
	esac
}

grabarLLamadaSospechosa() {
	local registroLLamada="$1"
	local idUmbral="$2"
	local anioMesDia="$3"
	local anioMes=$(echo "${anioMesDia::-2}")
	local idAgente
	local fechaYHora
	local numeroAreaA
	local numeroLineaA
	local numeroPaisB
	local numeroAreaB
	local numeroLineaB
	local tiempoConversacion
	parsearLLamada "$registroLLamada" idAgente fechaYHora numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion
	echo "grabando sospechosa"
	echo " $idUmbral "
	echo " $idCentral"
	echo "  $idAgente"
	echo " $tipoLLamada"
	echo " $fechaYHora"
	echo " $tiempoConversacion"
	echo " $numeroAreaA"
	echo " $numeroLineaA"
	echo " $numeroPaisB"
	echo " $numeroAreaB"
	echo " $numeroLineaB"
	echo " $anioMesDia"
	echo " $anioMes"
	local registroLLamadaSospechosa="$idCentral;$idAgente;$idUmbral;$tipoLLamada;$fechaYHora;$tiempoConversacion;\
	$numeroAreaA;$numeroLineaA;$numeroPaisB;$numeroAreaB;\
	$numeroLineaB;$anioMesDia"
	echo "aniomes $anioMes"
	echo "anioMesDia $anioMesDia"
	ruta="$idCentral""_""$anioMes"".csv"
	echo "$registroLLamadaSospechosa" >> "$PROCDIR/$ruta"
}

export -f verificarUmbralYgrabarLLamadaSospechosa