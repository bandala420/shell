#!/bin/bash
#Procesar archivos LOG
#Autor: Armando Domínguez
#Correccion y ampliacion daclark@gpomonse 2020-02
#Procesa todos los logs aun no procesados de todos los restaurantes de la franquicia indicada
#maindb y home deben coincidir
# ./procesa_log.sh mcd_gpomonse

main_db=$(awk 'BEGIN { print "'$1'" }')
home_franquicia=$main_db
source /root/scripts_globales/params/$main_db.sh
re='^[0-9]+$'
plog="20*.log"
variable="log_procesados.txt"
rest_ruta="/home/$home_franquicia/rest/"
complemento_ruta="/root/scripts_globales/logs_pos/complemento.sh"
estado=0

for i in $(ls $rest_ruta); do
        if [[ $i =~ $re ]]; then
	        pos_ruta="/home/$home_franquicia/rest/$i/logs/"
		for p in $(ls $pos_ruta); do
	                logs_ruta="/home/$home_franquicia/rest/$i/logs/$p/"
	                echo $logs_ruta
                        ruta_procesado=$logs_ruta$variable
                        if [ ! -f "$ruta_procesado" ]; then
                                touch $ruta_procesado
                                chown root.storage_serv $ruta_procesado && chmod 770 $ruta_procesado || chmod 776 $ruta_procesado &> /dev/null
                        fi
                        for a in $(ls $logs_ruta$plog); do
                                if [ -f $a ]; then
                                        tamano_subir=$(stat -c%s $a)
                                        if [ $tamano_subir != 0 ]; then
                                                archivo="$a"
                                                la=`echo -n $archivo | wc -m`
                                                valor=$la-12
                                                ap=${a:valor:la}
                                                estado=0
                                                busqueda=$(awk {'print $1'} "$ruta_procesado")
                                                for archivo in $busqueda; do
                                                        if [ $archivo == $ap ]; then
                                                                estado=1
                                                        fi
                                                done
                                                if [[ $estado == 0 ]]; then
                                                        $complemento_ruta $ap $p $i $main_db $home_franquicia $user $pass
                                                fi
                                        fi
                                fi
                        done
		done
	fi
done