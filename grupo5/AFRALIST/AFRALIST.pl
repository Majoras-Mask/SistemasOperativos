#!/usr/bin/perl
($file1,$file2) = @ARGV;

#VARIABLES GLOBALES----------------------------------------------------------
$todasCentrales = 0;
$todosAgentes = 0;
$todosUmbrales = 0;
$todosTiempollamada = 0;
$todosTipollamada = 0;
$todosCdA = 0;
$guardar = 0;
$pathEst = 0;
$accion = " ";

@filCentrales = ();
@filAgentes = ();
@filUmbrales = ();
@filTipoDeLlamada = ();
@filTiempoDeLlamada = ();
@filCdA = ();
@filCdB = ();
@inputLlamadas = ();
%filtros;
%filtroArchivos;
%statistics;
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

system("pgrep -c AFRALIST.pl > /tmp/path.txt");
open(ENTRADA,"</tmp/path.txt");
$REPODIR=<ENTRADA>;
close(ENTRADA);
if($REPODIR > 1){
	die"Ya esta corriendo\n";
}


#----------------------------------------------------------------------------
#VERIFICACION DE VARIABLES DE ENTORNO----------------------------------------
system('echo $REPODIR > /tmp/path.txt');
open(ENTRADA,"< /tmp/path.txt");
$REPODIR =<ENTRADA>;
chomp($REPODIR);
close(ENTRADA);

system('echo $MAEDIR > /tmp/path.txt');
open(ENTRADA,"< /tmp/path.txt");
$MAEDIR =<ENTRADA>;
chomp($MAEDIR);
close(ENTRADA);

system('echo $PROCDIR > /tmp/path.txt');
open(ENTRADA,"< /tmp/path.txt");
$PROCDIR =<ENTRADA>;
chomp($PROCDIR);
close(ENTRADA);	
if(("$REPODIR" eq "")||("$PROCDIR" eq "")||("$MAEDIR" eq "")){
	die"Algunas de las variables de entorno no se iniciaron correctamente\n";
}
#----------------------------------------------------------------------------
#VALIDACION PARAMETROS-------------------------------------------------------
my $size = @ARGV;
if($size == 0){die "Parametros invalidos, pruebe con AFRALIST -h\n";}
if($size == 1){
	for($ARGV[0]){
		if(/-h/){help();}
		elsif(/-r/){$accion = "consulta";}
		elsif(/-s/){$accion = "estadistica";}
		else{die "Parametros invalidos, pruebe con AFRALIST -h\n";}
	}
}
if($size == 2){
	if("$ARGV[0]" eq "-w"){
		$guardar = 1;
		for($ARGV[1]){
			if(/-r/){$accion ="consulta";}
			elsif(/-s/){$accion = "estadistica";}
			else{die "Parametros invalidos, pruebe con AFRALIST -h\n";}
		}
	}
	elsif("$ARGV[1]" eq "-w"){
		$guardar = 1;
		for($ARGV[0]){
			if(/-r/){$accion = "consulta";}
			elsif(/-s/){$accion = "estadistica";}
			else{die "Parametros invalidos, pruebe con AFRALIST -h\n";}
		}
	}else{die "Parametros invalidos, pruebe con AFRALIST -h\n";}
}
#----------------------------------------------------------------------------
#MENU PRINCIPAL--------------------------------------------------------------
my $loopConsulta = 0;
if("$accion" eq "consulta"){
	my $loopConsulta = 0;
	print"Sobre que tipo de archivos desea realizar consultas? \n";
	while($loopConsulta == 0){
		print"1-Llamas sospechosas\n";
		print"2-Consultas previas\n";
		my $tipoArchivo = <STDIN>;
		chop ($tipoArchivo);
		my $miConsulta == 0;
		if($tipoArchivo == 1){
			while($miConsulta == 0){
				menufiltroArchivosinputLlamadas();
				filtroRegistros();
				$miConsulta = 1;
			}
		}elsif($tipoArchivo == 2){
			while($miConsulta == 0){
				if(menufiltroArchivosPrevios() == 1){
					filtroRegistros();
					$miConsulta = 1;
				}else{
					last;
				}
			}	
		}else{
			print"Opcion invalida\n";
		}
		reinicializarVariablesGlobales();
		my $sms = "Desea realizar otra consulta ?";
		$loopConsulta = opcional($sms);
	}
}
elsif ("$accion" eq "estadistica"){
	if($guardar == 1){
		menuNombreArchivo();
	}
	while($loopConsulta == 0){
		#Genero input
		menuFiltroAnioMes();
		# Proceso input
		estadisticas();
		my $sms = "Desea realizar otra consulta ?";
		$loopConsulta = opcional($sms);
		reinicializarVariablesGlobales();
	}
}
#----------------------------------------------------------------------------
#----------------------------ESTADISTICA-------------------------------------
#----------------------------------------------------------------------------

#FILTRADO DE ARCHIVOS--------------------------------------------------------
sub menuFiltroAnioMes{
	my $loopConsulta = 0;
	while($loopConsulta == 0){
		menuEstadistica();
		my $opcion = <STDIN>;
		chop ($opcion);
#fecha puntal----------------------------------------------------------------
		if($opcion == 1){
			print"Ingrese la fecha (AAAAMM)\n";
			my $fecha = <STDIN>;chop($fecha);
			$fecha = "*_${fecha}";
			filtrarArchivos($fecha);
#rango de fechas-------------------------------------------------------------
		}elsif($opcion == 2){
			print"Ingrese la fecha desde(AAAAMM)\n";
			my $fechaDesde = <STDIN>;chop($fechaDesde);
			print"Ingrese la fecha hasta(AAAAMM)\n";
			my $fechaHasta = <STDIN>;chop($fechaHasta);
			if(validarFechas($fechaDesde,$fechaHasta) == 1){
				filtrarArchivosRangoFecha($fechaDesde,$fechaHasta);
			}
#todos los archivos----------------------------------------------------------
		}elsif($opcion == 3){
			my $path = "*_*";
			filtrarArchivos($path);
		}else{
			print"Opcion invalida\n";
		}
#----------------------------------------------------------------------------
		if(%filtroArchivos){	
			my $sms = "Quiere agregar mas archivos";
			$loopConsulta = opcional($sms);
		}else{print"Debe agregar al menos un archivos";}
	}
#levanto el input en memoria------------------------------------------------
	my $count = 0;
	for my $archivo (keys %filtroArchivos){
	    $count++;
	    open(my $fh, $archivo) or next;
    	$archivo = substr($archivo,-10,3);
	    while (my $linea = <$fh>) {
	    	$linea = "${linea};${archivo} \n";
	        chop ($linea);
	        push(@inputLlamadas,$linea);
	    }
	}
	print"Se trabajara con $count archivos\n"; 
}
#----------------------------------------------------------------------------
#Valido el ingreso de la fecha-----------------------------------------------
sub validarFechas{
	my $desde = shift;
	my $hasta = shift;
	if((soyNumerico($desde) == 0)||(soyNumerico($hasta) == 0)){
		print"Ha ingresado mal los parametros\n";
		return 0;
	}
	if((length($desde) != 6)||(length($hasta) != 6)){
		print"Ha ingresado mal los parametros\n";
		return 0;
	}
	my $anioD = substr($desde,0,4);
	my $mesD = substr($desde,4,2);
	my $anioH = substr($hasta,0,4);
	my $mesH = substr($hasta,4,2);
	if($anioD == $anioH){
		if($mesD == $mesH){
			print"Ha ingresado un rango invalido \n";
			return 0;
		}
		elsif($mesD < $mesH){
			print"Rango valido \n";
			return 1;
		}
		elsif($mesD > $mesH){
			print"Ha ingresado un rango invalido \n";
			return 0;
		}
	}elsif($anioD < $anioH){
		print"Rango valido \n";
		return 1;	
	}elsif($anioD > $anioH){
		print"Ha ingresado un rango invalido \n";
		return 0;
	}
	return 0;
}
#----------------------------------------------------------------------------
#Recorro todas las fechas dentro del rango ingresado-------------------------
sub filtrarArchivosRangoFecha{
	my $desde = shift;
	my $hasta = shift;
	my $anioD = substr($desde,0,4);
	my $mesD = substr($desde,4,2);
	my $count =0;
	my$patron = "*_${desde}";
	filtrarArchivos($patron);
	while("$desde" ne "$hasta"){
		if($mesD != 12){
			$mesD++;
			if(length($mesD)==2){$desde = "${anioD}${mesD}";}
			else{$desde = "${anioD}0${mesD}";}
		}else{
			$mesD = 1;
			$anioD++;
			$desde = "${anioD}0${mesD}"
		}
		$count++;
		my$patron = "*_${desde}";
		filtrarArchivos($patron);
		
	}
}
#----------------------------------------------------------------------------
#VERIFICA QUE HAYA ARCHIVOS QUE CORRESPONDAN CON ESE PATRON------------------
sub filtrarArchivos{
	my $patron = shift;
	my @filenames = glob("$PROCDIR/${patron}");
	foreach $doc (@filenames){
		if($filtroArchivos{"$doc"} != 1){
			$filtroArchivos{"$doc"} = 1;
		}
	}
}
#----------------------------------------------------------------------------
sub estadisticas{
	my $bigLoop = 0;
	while($bigLoop == 0){
		estadisticaOpciones();
		$opcion = <STDIN>;
		chop($opcion);
		my $opInva = 0;
		my $looper = 0;
		my $guardarSMS = 0;
		while($looper == 0){
			#centrales-------------------------------------------------------
			if($opcion == 1){
				while($opInva == 0){
					$looper = 1;
					print"1-Rankear por tiempo de conversacion\n";
					print"2-Rankear por cantidad de llamadas\n";
					my $opcion = <STDIN>;chop($opcion);
					if($opcion == 1){
						$opInva = 1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[0]}){
								$statistics{$llamada[0]} = $statistics{$llamada[0]}+$llamada[5];
							}else{
								$statistics{$llamada[0]} = $llamada[5];
							}
						}
					}elsif($opcion == 2){
						$opInva = 1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[0]}){
								$statistics{$llamada[0]} = $statistics{$llamada[0]}+1;
							}else{
								$statistics{$llamada[0]} = 1;
							}
						}
					}else{print"Opcion invalida\n";}
				}
				@master =();
				@master = levantarMaestros(1);
				my $guardarSMS = "***********************************************\n*******LLAMADAS SOSPECHOSAS DE CENTRALES*******\n***********************************************\n";
				mostrarDatos(0,$guardarSMS);
			}
			#agentes---------------------------------------------------------
			elsif($opcion == 2){
				$looper = 1;
				print"1-Rankear por tiempo cantidad de tiempo de conversacion\n";
				print"2-Rankear por cantidad de llamadas?\n";
				my $opcion = <STDIN>;chop($opcion);
				while($opInva == 0){
					if($opcion == 1){
						$opInva =1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[1]}){
								$statistics{$llamada[1]} = $statistics{$llamada[1]}+$llamada[5];
							}else{
								$statistics{$llamada[1]} = $llamada[5];
							}
						}	
					}elsif($opcion == 2){
						$opInva =1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[1]}){
								$statistics{$llamada[1]} = $statistics{$llamada[1]}+1;
							}else{
								$statistics{$llamada[1]} = 1;
							}
						}			
					}else{print"Opcion invalida\n";}
				}
				@master =();
				@master = levantarMaestros(2);
				my $guardarSMS = "***********************************************\n********LLAMADAS SOSPECHOSAS DE AGENTES********\n***********************************************\n";
				mostrarDatos(2,$guardarSMS);
			}
			#oficinas--------------------------------------------------------
			elsif($opcion == 3){
				$looper = 1;
				print"1-Rankear por tiempo cantidad de tiempo de conversacion\n";
				print"2-Rankear por cantidad de llamadas?\n";
				my $opcion = <STDIN>;chop($opcion);
				while($opInva == 0){
					if($opcion == 1){
						$opInva =1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[12]}){
								$statistics{$llamada[12]} = $statistics{$llamada[12]}+$llamada[5];
							}else{
								$statistics{$llamada[12]} = $llamada[5];
							}
						}	
					}elsif($opcion == 2){
						$opInva =1;
						foreach $linea (@inputLlamadas){
							@llamada = split(/;/,$linea);
							if($statistics{$llamada[12]}){
								$statistics{$llamada[12]} = $statistics{$llamada[12]}+1;
							}else{
								$statistics{$llamada[12]} = 1;
							}
						}	
					}else{print"Opcion invalida\n";}
				}
				my $guardarSMS = "***********************************************\n*******LLAMADAS SOSPECHOSAS DE OFICINAS*******\n***********************************************\n";
				mostrarDatos2($guardarSMS);
			}
			#destinos--------------------------------------------------------
			elsif($opcion == 4){
				$looper = 1;
				foreach $linea (@inputLlamadas){
					@llamada = split(/;/,$linea);
					if($statistics{$llamada[6]}){
						$statistics{$llamada[6]} = $statistics{$llamada[6]}+1;
					}else{
						$statistics{$llamada[6]} = 1;
					}
				}	
				@master = ();
				@master = levantarMaestros(5);
				my $guardarSMS = "***********************************************\n*******LLAMADAS SOSPECHOSAS EN DESTINOS*******\n***********************************************\n";
				mostrarDatos(1,$guardarSMS);
			}
			#umbrales--------------------------------------------------------
			elsif($opcion == 5){
				$looper = 1;
				foreach $linea (@inputLlamadas){
					@llamada = split(/;/,$linea);
					if($statistics{$llamada[2]}){
						$statistics{$llamada[2]} = $statistics{$llamada[2]}+1;
					}else{
						$statistics{$llamada[2]} = 1;
					}
				}
				my $guardarSMS = "***********************************************\n*******LLAMADAS SOSPECHOSAS DE UMBRALES*******\n***********************************************\n";
				mostrarDatos3($guardarSMS);	   
			}
			else{
				 print"Opcion invalida \n";
			}
		}
		%statistics = undef();
		my $sms = "Desea realizar otra consulta sobre el set de datos?";
		$bigLoop = opcional($sms);
		#ACA VA LIMPIEZA DE HASH
		undef %statistics;
	}
}
#----------------------------------------------------------------------------
#Muestro datos---------------------------------------------------------------
sub mostrarDatos{
	my $num = shift;
	my $smsGuar = shift;
	my $loop = 0;
	my @ordenado = ();
	if($guardar != 0) {
		open(FILE,">> $pathEst");
		print FILE "$smsGuar";
	}
#------------ ordeno los datos que quiere el usuario-------------------------
	foreach my $key  (sort { $statistics{$b} <=> $statistics{$a} } keys %statistics)  { 
		#print "$key=$statistics{$key}\n";
		push(@ordenado,$key);
	}
#----------------------------------------------------------------------------

	while($loop == 0){	
		print"1-Para mostrar ranking\n";
		print"2-Para mostrar el mayor\n";
		my $op = <STDIN>;chop($op);
#--------------------------------------
		if($op == 1){
			$loop = 1;
			foreach $algo (@ordenado){
				foreach $aux (@master){
					@auxSplit = split(/;/,$aux);
					if("$auxSplit[$num]" eq "$algo"){
						if($guardar == 0){
							print"$statistics{$algo}: $aux \n";	
						}else{
							print"$statistics{$algo}: $aux \n";
							print FILE "$statistics{$algo}: $aux \n";
						}
					}
				}
			}	 
		}
#--------------------------------------
		elsif($op == 2){
			$loop = 1;
			foreach $aux (@master){
				@auxSplit = split(/;/,$aux);
				if("$auxSplit[$num]" eq "$ordenado[0]"){
					if($guardar == 0){
						print"$statistics{$ordenado[0]}: $aux\n";	
					}else{
						print"$statistics{$ordenado[0]}: $aux\n";
						print FILE "$statistics{$ordenado[0]}: $aux\n";
					}
				}
			}
		}
		else{
			print"Opcion invalida\n";
		}
	}
}

sub mostrarDatos2{
	my $smsGuardar = shift;
	if($guardar != 0) {
		open(FILE,">> $pathEst");
		print FILE "$smsGuardar";
	}

	my @ordenado = (); 
	foreach my $key  (sort { $statistics{$b} <=> $statistics{$a} } keys %statistics)  {  
		push(@ordenado,$key);
	}
	my $loop = 0;
	while($loop == 0){
		print"1-Para mostrar ranking\n";
		print"2-Para mostrar el mayor\n";
		my $op = <STDIN>;chop($op);	
		if($op == 1){
			$loop = 1;
			foreach $algo (@ordenado){
				if($guardar == 0){
					print"$statistics{$algo}: $algo\n";	
				}else{
					print"$statistics{$algo}: $algo \n";	
					print FILE "$statistics{$algo}: $algo\n";
				}
			}
		}
		elsif($op == 2){
			$loop = 1;
				if($guardar == 0){
					print"$statistics{$ordenado[0]}: $ordenado[0]\n";	
				}else{
					print"$statistics{$ordenado[0]}: $ordenado[0]\n";
					print FILE "$statistics{$ordenado[0]}: $ordenado[0]\n";
				}
		}
		else{
			print"Opcion invalida\n";
		}
	}

	close(FILE);
}
sub mostrarDatos3{
	my $smsGuardar = shift;
	if($guardar == 1) {
		open(FILE,">> $pathEst");
		print FILE "$smsGuardar";
	}
	my @ordenado = ();
	foreach my $key  (sort { $statistics{$b} <=> $statistics{$a} } keys %statistics)  {
		if($statistics{$key} >1){
			push(@ordenado,$key);
		}
	}
	my $size = @ordenado;
	if($size != 0){
		foreach $algo (@ordenado){
			if($guardar == 0){
				print"$statistics{$algo}: $algo\n";	
			}else{
				print"$statistics{$algo}: $algo\n";	
				print FILE "$statistics{$algo}: $algo\n";
			}
		}
	}else{
		if($guardar == 0){
			print"No hay umbrales con mas de una llamada sospechosa\n";	
		}else{
			print"No hay umbrales con mas de una llamada sospechosa\n";	
			print FILE "No hay umbrales con mas de una llamada sospechosa\n";
		}
		
	}
	close(FILE);
}
#----------------------------------------------------------------------------
#elegir un nombre valido para el archivo a guardar---------------------------
sub menuNombreArchivo{
	my $valido = 0;
	my $nombre = 0;
	my $sizeVal = 0;
	my @validacion = ();

	while ($valido == 0){
		print"Indique el nombre del archivo donde se guardar los datos\n";
		$nombre = <STDIN>;
		chop($nombre);
		$nombre = "$REPODIR/${nombre}";
		if(-e $nombre){
			print"Ya existe un un archivo con ese nombre, por favor elija otro\n";
		}else{
			print"Nombre valido \n";
			$valido = 1;
			$pathEst = ${nombre};
		}	
	}

	open(FILE,"> $pathEst");
	print FILE "Archivo de estadistica\n";
	close(FILE);

}
#----------------------------------------------------------------------------
#-------------------------------CONSULTA-------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#MENU DE CONSULTAS PREVIAS Y DE LLAMADAS SOSPECHOSAS-------------------------
#ADEMAS FILTRA POR ARCHIVOS--------------------------------------------------

sub menufiltroArchivosinputLlamadas{
	my $opVal = 0;
	while($opVal == 0){
		
		print("Ingrese el filtro de archivos(OFICINA_AAAAMM)\n");
		print("* significa todos(ej: *_AAAAMM- Todos las oficinas de cierto anio mes)\n");
		my $filtro = <STDIN>;
		chop ($filtro);
		filtrarArchivos($filtro);
		my $sms = "Desea agregar mas archivos?";
		$opVal = opcional ($sms);
	}
	my $count = 0;
	for my $archivo (keys %filtroArchivos){
	    $count++;
	    open(my $fh, $archivo) or next;
	    while (my $linea = <$fh>) {
	        chop ($linea);
	        push(@inputLlamadas,$linea);
	    }
	}
	print"Se han usado los datos de $count archivos\n";
}

sub menufiltroArchivosPrevios{
    my $opVal = 0;
	opendir(my $dh, $REPODIR) or die "Not a directory";
    if(scalar(grep { $_ ne "." && $_ ne ".." } readdir($dh)) != 0){
    	while($opVal == 0){
	        print "Indique el numero de archivo de llamadas sospechosas que desea consultar(numero de 3 digitos)\n";
	        my $num = <STDIN>;
	        chop ($num);
	        if(length($num)== 3){
	            $num = "$REPODIR/subllamadas.$num";
	            open(my $fh, $num) or next;
	            while (my $linea = <$fh>) {
	                chop ($linea);
	                push(@inputLlamadas,$linea);
	            } 
	        }else{
	            print"Numero mal ingresado\n";
	            next;        
	        }
	        my $sms = "Desea agregar otro archivo de llamadas sospechosas?";
	        $opVal = opcional($sms);
	    }
	    return 1;	
    }
    else{
    	print"No se poseen archivos de consultas previas\n";
   		return 0;
   	}  
}
#----------------------------------------------------------------------
#FILTRO POR REGISTROS 
sub filtroRegistros(){
	print"filtroRegistros\n";
	my $notEnd = 0;
	my $sms = "Desea agregar otro filtro?";
	my $hayfiltro = 0;
	while($notEnd == 0){

		filtros();
		my $opcion = <STDIN>;
		chop($opcion);

		for($opcion){
			#CENTRALES
			if(/1/){
				if($todasCentrales == 1){
					print "Ya pidio que se ingresen todas las centrales \n";
					last;
				}
				else{
					my $path  = "$MAEDIR/CdC.mae";
					local %centrales = leerArchivo($path,0);
					while ($noLoop == 0){
						print"Ingrese el central(si quiere todas ingrese *)\n";
						my $central = <STDIN>;
						chop($central);
						if($central eq '*'){
							print"Todas las centrales\n";
							$todasCentrales = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							if($centrales{$central} == 1){
								print "Central agregada \n";
								push (@filCentrales, $central);
								$hayfiltro =1;
							}else{
								print"Central no valida \n";
							}
							$noLoop = opcional($sms);
						}
					}
				}
			}
			#AGENTES
			elsif(/2/){
				if($todosAgentes == 1){
					print "Ya pidio que se ingresen todas los agentes \n";
					last;
				}
				else{
					my $path  = "$MAEDIR/agentes.mae";
					local %agentes = leerArchivo($path,2);
					while ($noLoop == 0){
						print"Ingrese el agente(si quiere todos ingrese *)\n";
						my $agente = <STDIN>;
						chop($agente);
						if($agente eq "*"){
							print"Agrego todos los agentes\n";
							$todosAgentes = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							if($agentes{$agente} == 1){
								print "Filtro agregado\n";
								push (@filAgentes, $agente);
								$hayfiltro =1;

							}else{
								print"Agente no valido \n";
							}
							$noLoop = opcional($sms);
						}
					}
				}
			#UMBRALES
			}
			elsif(/3/){
				if($todosUmbrales == 1){
					print "Ya pidio que se ingresen todas los umbrales \n";
					last;
				}
				else{
					my $path  = "$MAEDIR/umbrales.tab";
					local %umbrales = leerArchivo($path,0);
					while ($noLoop == 0){
						print"Ingrese el Umbral(si quiere todos ingrese *)\n";
						my $umbral = <STDIN>;
						chop($umbral);
						if($umbral eq "*"){
							print"Agrego todos los umbrales\n";
							$todosUmbrales = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							if($umbrales{$umbral} == 1){
								print "Filtro agregado \n";
								push (@filUmbrales, $umbral);
								$hayfiltro =1;

							}else{
								print"Umbral no valido \n";
							}
							$noLoop = opcional($sms);
						}
					}
				}

			}
			#TIPO DE LLAMADA
			elsif(/4/){
				if($todosTipollamada == 1){
					print "Ya pidio que se ingresen todas los tipos de llamadas \n";
					last;
				}
				else{
					my $path  = "$MAEDIR/tllama.tab";
					local %tLlamadas = leerArchivo($path,1);
					while ($noLoop == 0){
						print"Agrego todos los tipos de llamada(si quiere todos ingrese *)\n";
						my $tLlamada = <STDIN>;
						chop($tLlamada);
						if($tLlamada eq "*"){
							print"Todas las centrales\n";
							$todosTipollamada = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							if($tLlamadas{$tLlamada} == 1){
								print "Filtro agregado \n";
								push (@filTipoDeLlamada, $tLlamada);
								$hayfiltro =1;

							}else{
								print"Tipo de llamada no valida\n";
							}
							$noLoop = opcional($sms);
						}
					}
				}		
			}
			#TIEMPO DE LLAMADA
			elsif(/5/){
				if($todosTiempollamada == 1){
					print "Ya pidio que se ingresen todas los tiempos de llamadas \n";
					last;
				}
				else{
					while ($noLoop == 0){
						print"Ingrese el rango de la llamada (xxx;yyy)(x<y)(si quiere todos ingrese *)\n";
						my $tiempoLlamada = <STDIN>;
						chop($tiempoLlamada);
						if($tiempoLlamada eq "*"){
							print"Agrego todos los tiempos de llamadas\n";
							$todosTiempollamada = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							@rango = split(/;/,$tiempoLlamada);
							if((soyNumerico(@rango[0]) == 1)&&(soyNumerico(@rango[1]) == 1)){
								if(@rango[0] < @rango[1]){
									print "Filtro agregado \n";
									push (@filTiempoDeLlamada, $tiempoLlamada);
									$hayfiltro =1;
								}else{
									print"No es un rango valido\n";
								}
							}else{
								print"Alguno de los datos que ingreso no son validos\n";
								next;
							}
							$noLoop = opcional($sms);
						}
					}	
				}	
			}	
			#CdA + numero 
			elsif(/6/){
				if($todosCdA == 1){
					print "Ya pidio que se ingresen todas los codigos de area \n";
					last;
				}
				else{
					my $path1  = "$MAEDIR/CdA.mae";
					local %CdAs = leerArchivo($path1,1);
					while ($noLoop == 0){
						print"Ingrese el codigo de area y linea (CdA;linea)\n";
						my $numero = <STDIN>;
						chop($numero);
						if($numero eq "*"){
							print"Agrego todos los codigos de area\n";
							$todosCdA = 1;
							$noLoop = 1;
							$hayfiltro =1;		
						}else {
							@numeroCompleto = split(/;/,$numero);
							if((soyNumerico(@numeroCompleto[0]) == 1)&&(soyNumerico(@numeroCompleto[1]) == 1)){
								if($CdAs{@numeroCompleto[0]} == 1){
									print "Filtro agregado \n";
									push (@filCdA, $numero);
									$hayfiltro =1;
								}else{
									print"El codigo de area no es valido\n";
									next;
								}
							}else{
								print"Alguno de los datos que ingreso no son validos\n";
								next;
							}
							$noLoop = opcional($sms);
						}
					}	
				}	
			}
			#No mas filtros	
			elsif (/0/){
				if($hayfiltro == 1){
					if(@filCentrales != 0){$filtros{central} = 1;}
					if(@filAgentes != 0){$filtros{agente} = 1;}
					if(@filUmbrales != 0){$filtros{umbral} = 1;}
					if(@filTipoDeLlamada != 0){$filtros{tLlamada} = 1;}
					if(@filTiempoDeLlamada != 0){$filtros{tiempoLlamada} = 1;}
					if(@filCdA != 0){$filtros{CdA} = 1;}
					if(@filCdB != 0){$filtros{CdB} = 1;}
					my $i = 0;
					filtrarRegistros();
					$notEnd = 1;
				}else{
					print"Debe seleccionar al menos un filtro, para no realizar una busqueda a ciegas\n";
				}
			}
			#OPCION NO VALIDA
			else{
				print"Opcion valida\n";		
			}

		}
		$noLoop = 0;
	}
}
sub filtrarRegistros{
	my $flag = 0;
	my $filtrado = 0;
	my $size = 0;
	my @line = ();
	my @listaParaGuardar = ();
	foreach my $algo (@inputLlamadas){
		$filtrado = 0;
		$size = 0;
		@line = split(/;/, $algo);
		if($todasCentrales != 1){
			if($filtros{central}== 1 && $filtrado == 0){
				$size = @filCentrales;
				for(my $i =0;$i<$size;$i++){ 
					$filtrado = filtrarlinea($filCentrales[$i],$line[0]);
					if($filtrado == 0){last;}
				}	
			}
		}
		if($todosAgentes != 1){		
			if($filtros{agente}== 1 && $filtrado == 0){
				$size = @filAgentes;

				for(my $i =0;$i<$size;$i++){ 
					$filtrado = filtrarlinea(@filAgentes[$i],@line[1]);
					if($filtrado == 0){last;}
				}
			}
		}
		if($todosUmbrales != 1){
			if($filtros{umbral}== 1 && $filtrado == 0){
				$size = @filUmbrales;
				for(my $i =0;$i<$size;$i++){ 
					$filtrado = filtrarlinea($filUmbrales[$i],@line[2]);
					if($filtrado == 0){last;}
				}
			}
		}
		if($todosTipollamada != 1){
			if($filtros{tLlamada}== 1 && $filtrado == 0){
				$size = @filTipoDeLlamada;
				for(my $i =0;$i<$size;$i++){ 
					$filtrado = filtrarlinea($filTipoDeLlamada[$i],@line[3]);
					if($filtrado == 0){last;}
				}
			}
		}
		if($todosTiempoLlamada != 1){
			if($filtros{tiempoLlamada}== 1 && $filtrado == 0){
				$size = @filTiempoDeLlamada;
				for(my $i =0;$i<$size;$i++){
					$filtrado = filtrarlineaPorTiempo($filTiempoDeLlamada[$i],@line[5]);
					if($filtrado == 0){last;}
				}
			}
		}
		if($todosCdA != 1){
			if($filtros{CdA}== 1 && $filtrado == 0){
				$size = @filCdA;
				for(my $i =0;$i<$size;$i++){
					@linea = split(/;/,@filCdA[$i]);
					$filtrado = filtrarlinea(@linea[0],@line[6]);
					if ($filtrado == 0){
						$filtrado = filtrarlinea(@linea[1],@line[7]);
						if($filtrado == 0){last;}
					}
				}
			}
		}
		if($guardar == 0){
			if($filtrado == 0){
				$flag = 1;
				print" $algo \n---------------------------------------------\n";
			}
		}else{
			if($filtrado == 0){
				$flag = 1;
				print" $algo \n---------------------------------------------\n";
				push(@listaParaGuardar,$algo);
				}
		}
	}
	if($flag == 0 ){print"No hubo coincidencias ";}
	my $sizeGuardar = @listaParaGuardar;
	if($sizeGuardar != 0){
		my $path = guardarEnArchivo();

		# Abre el archivo (o lo crea si no existe)
		open (FILE, "> $REPODIR/$path")|| die "ERROR: No se pudo abrir el fichero $salida\n";
		#Scrive
		foreach my $linea (@listaParaGuardar){
			print FILE "$linea\n";
		}
		# Cierra el archivo
		close FILE; 
	}
}
sub filtrarlinea{
	my $fil = shift;
	my $toFil = shift;
	if($fil eq $toFil) {
		return 0;
	}
	return 1;
}
sub filtrarlineaPorTiempo{
	my $fil = shift;
	my $toFil = shift;
	my @rango = split(/;/,$fil);
	if((@rango[0]<=$toFil)&&(@rango[1]>=$toFil)) {
		return 0;
	}
	return 1;
}
#----------------------------------------------------------------------
#MANEJO DE ARCHIVOS
sub guardarEnArchivo{

	my $numero = 0;
	my $nombre = "subllamadas";
	my @filenames = glob("$REPODIR/subllamadas.*");
	my $cantidadArchivos = @filenames;
	foreach $subLlamada (@filenames){
		my $aux = substr($subLlamada,-3,3);
		if ($numero < $aux){$numero = $aux;} 
	}
	$numero = $numero + 1;
	if(length($numero) == 1){
		$nombre = "${nombre}.00${numero}";
	}elsif(length($numero) == 2){
		$nombre = "${nombre}.0${numero}";
	}else{
		$nombre = "${nombre}.${numero}";
	}
	return $nombre;
}
sub leerArchivo{

	my $filename = shift @_;
	my $campo = shift @_;	
	open(my $fh, $filename)
		or die "Could not open file '$filename' $!";
	my %hash;
	while (my $linea = <$fh>) {
		chomp $linea;
		
		my @words = split /;/, $linea;
		$hash{@words[$campo]} = 1;	
	}
	return %hash;
}
#----------------------------------------------------------------------------
#UTILIDADES------------------------------------------------------------------

#----------------------------------------------------------------------------
#levanta en memoria el archivo de centraless que se especifique--------------
sub levantarMaestros{
	my $num = shift;
	my @maestro = shift;
	my $path;
	if($num == 1){
		$path = "$MAEDIR/CdC.mae";
	}elsif($num == 2){
		$path = "$MAEDIR/agentes.mae";
	}elsif($num == 3){
		$path = "$MAEDIR/umbrales.tab";		
	}elsif($num == 4){
		$path = "$MAEDIR/tllama.tab";		
	}elsif($num == 5){
		$path = "$MAEDIR/CdA.mae";		
	}elsif($num == 6){
		$path = "$MAEDIR/CdB.mae";		
	}
    open(my $fh, $path) or next;
    while (my $linea = <$fh>) {
        chop ($linea);
        push(@maestro,$linea);
    } 
    return @maestro;
}
#----------------------------------------------------------------------------
#verifica que haya archivos que correspondan con dicho patron
sub filtrarArchivos{
	my $patron = shift;
	#print "Patron para filtrar\n$PROCDIR/${patron} \n";
	my @filenames = glob("$PROCDIR/${patron}");
	foreach $doc (@filenames){
		if($filtroArchivos{"$doc"} != 1){
			$count++;
			$filtroArchivos{"$doc"} = 1;
		}
	}
}
sub reinicializarVariablesGlobales{
	$todasCentrales = 0;
	$todosAgentes = 0;
	$todosUmbrales = 0;
	$todosTiempollamada = 0;
	$todosTipollamada = 0;
	$todosCdA = 0;

	@filCentrales = ();
	@filAgentes = ();
	@filUmbrales = ();
	@filTipoDeLlamada = ();
	@filTiempoDeLlamada = ();
	@filCdA = ();
	@filCdB = ();
	@inputLlamadas = ();
	undef %filtros;
	undef %filtroArchivos; 
	undef %statistics;
}
sub opcional{
	my $sms = shift;
	while(){
		print "$sms \n";
		print("1 - SI \n2 - NO \n");
		$op =<STDIN>;
		chop ($op);
		if($op == 2) {return 1;}
		elsif($op == 1){return 0;}
	}	
}

sub soyNumerico{
	my $variable = shift;
	if ($variable =~ /^[+-]?\d+$/) {return 1;}
	return 0;
}
#----------------------------------------------------------------------------
#PRITNS----------------------------------------------------------------------
sub estadisticaOpciones{
	print("1- Central con mas llamadas sospechosas\n");
	print("2- agente con mas llamadas sospechosas\n");
	print("3- oficina con mas llamadas sospechosas\n");
	print("4- Destino con mas llamadas sospechosas\n");
	print("5- Ranking de umbrales\n");
}
sub filtros{
	print("Indique informacion que desea\n");
	print("1- Sobre centrales\n");
	print("2- Sobre agente\n");
	print("3- Sobre umbral\n");
	print("4- Tipo de llamada\n");
	print("5- Tiempo de llamada\n");
	print("6- Numero de area (area + numeo de linea)\n");
	print("0- terminar de agregar filtros\n");
}
sub menuEstadistica{
	print("1- Filtrar por una fecha\n");
	print("2- Filtrar por un rango de fechas\n");
	print("3- Utilizar todos los archivos disponibles\n");
}
sub help{
	print "Bienvenido al sistema de informes de SisPro.\n";
	print "Para realizar una consulta ingrese AFRALIST.pl -r\n";
	print "- La consulta se realizara sobre los archivos de llamadas sospechosas o sobre archivos generados anteriormente por este comando.\n";
	print "- Si asi lo desea podra guardar la salida de la consulta en un archivo agregando -w como parametro del comando\n";
	print "- Los cuales, mediante el menu, podra filtrar por oficina o por aniomes de llamada o podra seleccionar todos.\n ";
	print "- En el menu siguiente podra filtrar los archivos segun sus registros (centrales, agentes, etc).\n";
	print "\n";
	print "Para realizar una estadistica ingrese AFRALIST.pl -s\n";
	print "- La estadistica se realizara sobre los archivos de llamadas sospechosas.\n";
	print "- Al igual que en consulta, si agrega el parametro -w se guardan los datos en un archivo, pero se le pedira el nombre que desea para el mismo.\n";
	print "- Podra filtrar los archivos por fecha, por rango de fechas o podra seleccionar todos.\n"; 
	print "- Luego podra ver rankings de llamadas sospechosas segun diferentes parametros(segun centrales, segun oficinas, etc).\n";
}