#!/bin/bash
# -*- coding: utf-8 -*-
# Author: Daniel Bandala @ gpomonse 04-2021
# Procesa los archivos de horarios recibidos en el restaurante indicado
# bash horarios_empleados.sh mcd_gpomonse 00080

# Input variables
main_db=$1
restaurant_folder=$2
if [ -z "$restaurant_folder" ];then
    echo Faltan argumentos
    exit -1
fi
# Variables
scripts=/root/scripts_globales/horarios
registerFile=$scripts/horarios_empleados.txt.$1_$2
sortedDates=$scripts/sortedDates.txt.$1_$2
filter=$scripts/filter.awk
if [ -f "$registerFile" ];then
    rm $registerFile || exit -1
fi
# Check permissions
rest_path=/home/$main_db/rest/$restaurant_folder/horarios/empleados
cd $rest_path || exit -1
# Import db parameters
source /root/scripts_globales/params/$main_db.sh

# Ciclo para todos los horarios recibidos en ese restaurante
for horFile in $(ls -d *.txt.gz); do
	# Copy file to scripts path
	gzFile=$scripts/$horFile
	cp $horFile $gzFile
	# Unzip file
	gunzip -f $gzFile
	fileName=$(echo $gzFile | sed 's/\.[^.]*$//')
	# Process file
	awk -v rest=MX$restaurant_folder -f $filter $fileName > $registerFile

	# Obtener rango de fechas
	cat $registerFile | awk -F',' '{print $2}' | sort --unique > $sortedDates
	startDate="$(head -n 1 $sortedDates)"
	endDate="$(tail -n 1 $sortedDates)"
	# Insercion en la base de datos borrando antes filas en el rango de fechas
	if [[ -n "$startDate" && -n "$endDate" && -n "$REST" ]]; then
		mysql $main_db -u "webapp" -p"W2e0p1A9pp" -Nse "DELETE FROM horarios_empleados WHERE fecha BETWEEN '$startDate' AND '$endDate' AND rest='MX$restaurant_folder'"
	fi

	# Upload schedule information
	tamano_subir=$(stat -c%s $registerFile)
	echo "Tamaño integridad_pos.txt = $tamano_subir B"
	if [ "$tamano_subir" -gt "1" ]; then
		mysqlimport -u $user --password=$pass --fields-terminated-by=, --replace --local $main_db $registerFile
	fi
	# Delete tmp data file
	rm $fileName
	rm $registerFile
	rm $sortedDates
	# Create procesados folder in case it doesnt exist
	if [ ! -d "procesados" ]; then
		mkdir procesados
		chown root.storage_serv procesados
		chmod 770 procesados
	fi
	# Move schedule file to avoid reprocess
	mv $horFile procesados/$horFile
done