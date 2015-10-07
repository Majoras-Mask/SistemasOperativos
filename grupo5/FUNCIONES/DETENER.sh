#!/bin/bash
pid=$(ps aux | grep "$1" | grep -v 'DETENER' | grep -v 'grep' | head -n 1 | awk '{print $2}')
if [ ! -z $pid ]; then
	kill $pid
	echo "Se detuvo el proceso $1 con PID: $pid"
	exit 0
else
	echo "No se pudo detener el proceso $1, ya que no esta siendo ejecutado."
	exit 1
fi
