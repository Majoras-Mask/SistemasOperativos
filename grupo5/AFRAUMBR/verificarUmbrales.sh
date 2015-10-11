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
	local anioMesDia="$4"
	conUmbral="$5"
	sinUmbral="$6"
	sospechosas="$7"
	#echo "tipoLLamada = $tipoLLamada"
	local idAgente
	local fechaYHora
	local numeroAreaA
	local numeroLineaA
	local numeroPaisB
	local numeroAreaB
	local numeroLineaB
	local tiempoConversacion
	#echo "registroLLamada = $registroLLamada"
	parsearLLamada "$registroLLamada" idAgente fechaYHora numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion

	local linea
	local cont=0
	while read linea || [ -n "$linea" ]
	do
		cont=`expr $cont + 1`
		match1=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;\
			$tipoLLamada;$numeroAreaB;[0-9]*;[A-Z][a-z]*//")
		match2=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;\
			$tipoLLamada;$numeroAreaB;[0-9]*;[0-9]*;[A-Z][a-z]*//")
		
		#echo "match = $match"
		if [ "$match1" == "" ] || [ "$match2" == "" ] 
		then
			if [ "$match1" == "" ]
				then
				verificarUmbral "$linea" "$tiempoConversacion" conUmbral sinUmbral
				local res="$?"
				if [ "$res" -eq  1 ]
					then
					eval "sospechosas=`expr $sospechosas + 1 `" 
					grabarLLamadaSospechosa "$idUmbral" "$idCentral" \
					"$idAgente" "$tipoLLamada" "$fechaYHora"\
					 "$tiempoConversacion" "$numeroAreaA" "$numeroLineaA"\
					 "$numeroPaisB" "$numeroAreaB" "$numeroLineaB" "$anioMesDia"
					 "$Activo"
				fi
			else
				verificarUmbralConMasDeUno "$linea" "$tiempoConversacion" conUmbral sinUmbral
				local res="$?"
				if [ "$res" -eq  1 ]
					then
					eval "sospechosas=`expr $sospechosas + 1 `"
					idUmbral=$(echo $linea | awk -F';' '{ print $1 }')
					Activo=$(echo $linea | awk -F ';' '{print $NF}')
					grabarLLamadaSospechosa "$idUmbral" "$idCentral" \
					"$idAgente" "$tipoLLamada" "$fechaYHora"\
					 "$tiempoConversacion" "$numeroAreaA" "$numeroLineaA"\
					 "$numeroPaisB" "$numeroAreaB" "$numeroLineaB" "$anioMesDia"
				fi
			fi	
		break
		fi
	done < "$UMBRALES"

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
	conUmbral="$3"
	sinUmbral="$4"
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
			return 1
		fi
		return 0
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
	conUmbral="$3"
	sinUmbral="$4"
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
			return 1
		fi
		return 0
		;;
	"$INACTIVO")
	sinUmbral=`expr $sinUmbral + 1`
		echo "sin umbral"
	return 0
	;;
	esac
}

grabarLLamadaSospechosa() {
	local idUmbral="$1"
	local idCentral="$2"
	local idAgente="$3"
	local tipoLLamada="$4"
	local fechaYHora="$5"
	local tiempoConversacion="$6"
	local numeroAreaA="$7"
	local numeroLineaA="$8"
	local numeroPaisB="$9"
	local numeroAreaB="$10"
	local numeroLineaB="$11"
	local anioMesDia="$12"
	local activo="$13"
	local anioMes=$("${anioMesDia::-2}]")
	local registroLLamadaSospechosa="$idCentral;$idAgente;\
	$idUmbral;$tipoLLamada;$fechaYHora$tiempoConversacion;\
	$numeroAreaA;$numeroLineaA;$numeroPaisB;$numeroAreaB;\
	$numeroLineaB,$anioMesDia"
	echo "$registroLLamadaSospechosa" >> "$PROCDIR"/"$idCentral_$anioMes"
}

export -f verificarUmbralYgrabarLLamadaSospechosa