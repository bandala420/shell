#!/bin/bash
#Procesar archivos LOG
#Autor: Armando Domínguez
#./complemento.sh archivo pos rest main_db home_rest

archivo=$(awk 'BEGIN { print "'$1'" }')
pos=$(awk 'BEGIN { print "'$2'" }')
rest=$(awk 'BEGIN { print "'$3'" }')
main_db=$(awk 'BEGIN { print "'$4'" }')
home_franquicia=$(awk 'BEGIN { print "'$5'" }')

scripts="/root/scripts_globales"
identifier=$(date +"%Y%m%d%H%M%S")
mkdir -p "$scripts/logs_pos/$main_db/"
ruta_actual="$scripts/logs_pos/$main_db/"
ruta_awk="$scripts/logs_pos/log_ticket.awk"
ruta_filtro="$scripts/logs_pos/filtro.awk"
ruta_destinada="/home/$home_franquicia/rest/$rest/logs/$pos/$archivo"
procesados_ruta="/home/$home_franquicia/rest/$rest/logs/$pos/log_procesados.txt"
ruta_base="$scripts/logs_pos/$main_db/venta_ticket_log.txt.$1_$2_$3_$4_$5_$identifier"
temporal="temporal_$1_$2_$3_$4.csv"

tamano_subir=$(du -h $ruta_destinada | awk '{print $1;}')
if [ $tamano_subir != 0 ]
then

touch $ruta_base
chown root.developers $ruta_base


cp $ruta_destinada $ruta_actual$archivo
mv $ruta_actual$archivo $ruta_actual$archivo.gz
gzip -d $ruta_actual$archivo.gz
$ruta_awk $ruta_actual$archivo > $ruta_actual$temporal
$ruta_filtro $ruta_actual$temporal > $ruta_base
fecha=`date`
estado=$(cat $ruta_base | awk '{if(NR==1) {print $1}}')
tamano_subir=$(stat -c%s $ruta_base)

if [ $tamano_subir != 0 ]
then
        if [ $estado == 'Errores' ]
        then
                echo Error al procesar $archivo >> $procesados_ruta
        else
				tamano_subir=$(du -h $ruta_base | awk '{print $1;}')
				if [ $tamano_subir != 0 ]
				then
#                                echo $archivo $pos $rest $main_db
                                mysqlimport -u $6 --password=$7 --fields-terminated-by=, --ignore --local $main_db $ruta_base
                                echo $archivo $pos $rest $fecha >> $procesados_ruta
				echo "OK: $archivo $pos $rest $fecha TAMAÑO= $tamano_subir"
				
				else
				echo "ALGO OCURRIO ARCHIVO VACIO: $archivo $pos $rest $fecha TAMANO= $tamano_subir"
				fi
        fi
else
        echo $archivo $pos $rest $fecha >> $procesados_ruta
	 echo $archivo $pos $rest
fi

if [ -f $ruta_actual$archivo ]
 then
        rm $ruta_actual$archivo
fi

if [ -f $ruta_actual$temporal ]
 then
        rm $ruta_actual$temporal
fi

if [ -f $ruta_base ]
 then
        rm $ruta_base
#	mv $ruta_base $ruta_base.$rest.$pos
fi


 if [ -f $ruta_actual$archivo.gz ]
 then
        rm $ruta_actual$archivo.gz
fi

fi
