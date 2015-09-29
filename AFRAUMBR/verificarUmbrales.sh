#!/Bin/bash
source clasificarLLamada.sh
source parserLLamada.sh
UMBRALES="MAEDIR/umbrales.mae"
verificarUmbral()
{
	local registroLLamada="$1"
	local tipoLLamada="$2"
	echo "tipoLLamada = $tipoLLamada"
	local idAgente
	local numeroAreaA
	local numeroLineaA
	local numeroPaisB
	local numeroAreaB
	local numeroLineaB
	local tiempoConversacion
	echo "registroLLamada = $registroLLamada"
	parsearLLamada "$registroLLamada" idAgente numeroAreaA numeroLineaA numeroPaisB numeroAreaB numeroLineaB tiempoConversacion

	local linea
	local cont=0
	while read linea
	do
		cont=`expr $cont + 1`
		local umb1=$(echo $linea | awk -F';' '{print $5}')
		local umb2=$(echo $linea | awk -F';' '{print $6}')
		local act=$(echo $linea | awk -F';' '{print $ 7}')
		match=$( echo $linea | sed "s/$cont;//;s/$numeroAreaA;//;s/$numeroLineaA;//;s/$tipoLLamada;//;s/$umb1;$umb2;$act//")
		echo "match = $match"
		if [ "$match" == "" ] 
		then
			local umbralActivo=$( echo linea | awk F';' '{print $7}')
			case "$umbralActivo" in
				"Activo")
				local umbral1=	umbralActivo=$( echo linea | awk F';' '{print $5}')
				local umbral2=	umbralActivo=$( echo linea | awk F';' '{print $6}')
				umbral1=`expr umbral1`
				umbral2=`expr umbral2`
				maximoUmbral umbral1 umbral2 
				maximo="$?"
				if [ "$tiempoConversacion" -gt "$maximo" ]
					then
					echo "grabar llamada sospechosa"
				fi
				;;
				"Inactivo")
				break
				;;
			esac
		break
		fi
	done < "$UMBRALES"




	case "$tipoLLamada" in
		"$ES_DDI")
			echo ""
			;;
		"$ES_DDN")
			echo ""
			;;
		"$ES_LOCAL")
			echo ""
			;;
	esac
}

maximoUmbral()
{
	local umb1=$1
	local umb2=$2
	if [ "$umb1" -gt "$umb2" ]
		then
		return `expr $umb1`
	fi
	return `expr"$umb2` 
}