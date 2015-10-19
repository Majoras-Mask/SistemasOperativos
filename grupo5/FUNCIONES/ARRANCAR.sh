#!/bin/bash
if [ -z "$CONFDIR" ] || [ -z "$BINDIR" ] || [ -z "$MAEDIR" ] || [ -z "$NOVEDIR" ] || [ -z "$ACEPDIR" ] || [ -z "$PROCDIR" ] || [ -z "$REPODIR" ] || [ -z "$LOGDIR" ] || [ -z "$RECHDIR" ]; then
	echo "Variables de entorno no inicializadas."
	exit 1
else
	if [ -z $1 ]; then
		echo "Parametro faltante"
		exit 1
	else
		pid=$(ps aux | grep "$1" | grep -v 'ARRANCAR' | grep -v 'grep' | grep '/bin/bash' | head -n 1 | awk '{print $2}')
		if [ -z $pid ]; then
			"$BINDIR/$1" &
			echo $!
			exit 0
		else
			echo "No es posible arrancar $1 ya que esta siendo ejecutado."
			exit 1
		fi
	fi
fi
