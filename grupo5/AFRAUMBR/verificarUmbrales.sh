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
	while read linea
	do
		cont=`expr $cont + 1`
		match1=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroAreaB;[0-9]*;[A-Z][a-z]*//")
		match2=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroAreaB;[0-9]*;[0-9]*;[A-Z][a-z]*//")
		#echo "match = $match"
		if [ "$match1" == "" ] || [ "$match2" == "" ] 
		then
			if [ "$match1" == "" ]
				then
				verificarUmbral "$linea" "$tiempoConversacion"
				local res="$?"
				if [ "$res" -eq  1 ]
					then
					echo "grabar llamada sospechosa"
				fi
			else
				verificarUmbralConMasDeUno "$linea" "$tiempoConversacion"
				local res="$?"
				if [ "$res" -eq  1 ]
					then
					echo "grabar llamada sospechosa"
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
	
	local umbralActivo=$( echo "$linea" | awk -F';' '{print $8 }')
	case "$umbralActivo" in
	"$ACTIVO")
		#echo $linea
		local umbral1=$( echo $linea | awk -F';' '{ print $6 }')
		local umbral1=$( echo $linea | awk -F';' '{ print $7 }')
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
		echo "sin umbral"
	return 0
	;;
	esac
}
export -f verificarUmbralYgrabarLLamadaSospechosa