#!/Bin/bash
source clasificarLLamada.sh
source parserLLamada.sh
UMBRALES="MAEDIR/umbrales.mae"
ACTIVO="Activo"
INACTIVO="Inactivo"
verificarUmbral()
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
		match=$( echo $linea | sed "s/$cont;$numeroAreaA;$numeroLineaA;$tipoLLamada;$numeroAreaB;[0-9]*;[A-Z][a-z]*//")
		#echo "match = $match"
		if [ "$match" == "" ] 
		then
			local umbralActivo=$( echo "$linea" | awk -F';' '{print $7}')
			case "$umbralActivo" in
				"$ACTIVO")
				#echo $linea
				local umbral1=$( echo $linea | awk -F';' '{print $5}')
				local umbral2=$( echo $linea | awk -F';' '{print $6}')
				echo "umbral1 = $umbral1"
				echo "umbral2 = $umbral2"
				echo "tiempoConversacion = $tiempoConversacion"
				umbral1=`expr $umbral1`
				umbral2=`expr $umbral2`
				maximoUmbral "$umbral1" "$umbral2" 
				maximo="$?"
				tiempoConversacion=`expr $tiempoConversacion`
				if [ "$tiempoConversacion" -gt "$maximo" ]
				then
					echo "grabar llamada sospechosa"
					let a=4
				fi
				;;
				"$INACTIVO")
					let a=5
				#echo "sin umbral"
				break
				;;
			esac
		break
		fi
	done < "$UMBRALES"




	#case "$tipoLLamada" in
	#	"$ES_DDI")
	#		echo ""
	#		;;
	#	"$ES_DDN")
	#		echo ""
	#		;;
	#	"$ES_LOCAL")
	#		echo ""
	#		;;
	#esac
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

export -f verificarUmbral