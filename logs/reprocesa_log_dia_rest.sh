#!/bin/bash
#borra un dia y lo reprocesa PARA 1 restaurante especifico!
#DE UNA FRANQUICIA
#Borra TODA LA INFO DEL DIA AUNQUE NO EXISTAN LOGS QUE REEMPLACEN ESTA INFO
#Busca y desempaqueta de manera automatizada en los respaldos!!!!
#
#Daclark@gpomonse 2021-04
#
#./reprocesa_log_dia_rest.sh fecha franquicia rest(a 4 digitos num)
#./reprocesa_log_dia_rest.sh 2020-12-12 mcd_grill 0080

#clear
echo "Fecha = $1"
echo "Main db = $2"
echo "rest = $3"

main_db=$2
scripts="/root/scripts_globales/logs_pos"
home="/home/$main_db/rest"

anio=$(awk 'BEGIN { print substr("'$1'",1,4) }')
mes=$(awk 'BEGIN { print substr("'$1'",6,2) }')
dia=$(awk 'BEGIN { print substr("'$1'",9,2) }')

re='^[0-9]+$'
if ! [[ $anio =~ $re ]] ; then
   echo "Año: Not a number" >&2; exit 1
elif ! [[ $mes =~ $re ]] ; then
   echo "Mes: Not a number" >&2; exit 1
elif ! [[ $dia =~ $re ]] ; then
   echo "dia: Not a number" >&2; exit 1
fi


archivo=$anio$mes$dia.log


echo "Buscando $archivo ..."

if [ -d "$home" ];
then
echo "Iniciando para Todas las pos en: $home/0$3/logs"
source /root/scripts_globales/params/$main_db.sh

##FUNCION
procesa_log () {
#1 = origen
#2 = archivo
#3 = main_db
#4 = user
#5 = pass
	#echo "procesando archivo en $1/$2 " 
	cp $1/$2 $scripts/$main_db/
	mv $scripts/$main_db/$2 $scripts/$main_db/$2.gz
	gzip -d $scripts/$main_db/$2.gz
	$scripts/log_ticket.awk $scripts/$main_db/$2 > $scripts/$main_db/venta_ticket_log.tmp
	$scripts/filtro.awk $scripts/$main_db/venta_ticket_log.tmp > $scripts/$main_db/venta_ticket_log.txt
	rm $scripts/$main_db/$2
	tamano_subir=$(du -h $scripts/$main_db/venta_ticket_log.txt | awk '{print $1;}')
	if [ $tamano_subir != 0 ]
	then
 		mysqlimport -u $4 --password=$5 --fields-terminated-by=, --replace --local $3 $scripts/$main_db/venta_ticket_log.txt
                echo "$2 $1" >> $1/log_procesados.txt
		chown root.developers $1/log_procesados.txt
		chmod 770 $1/log_procesados.txt
                echo "OK: $1/2 TAMAÑO= $tamano_subir"
		rm $scripts/$main_db/venta_ticket_log.t*

        else
        echo "--->ALERTA---->ALGO OCURRIO ARCHIVO VACIO: $1/$2  TAMANO= $tamano_subir"
        fi
}

##FUNCION
borra_info () {
#1 = fecha
#2 = rest
#3 = main_db
#4 = user
#5 = pass
	query_borrar="DELETE FROM $3.venta_ticket_log WHERE $3.venta_ticket_log.rest = '$2' AND $3.venta_ticket_log.business_date  ='$1'"
	resultado=$(mysql --login-path=$main_db -s -N -e "$query_borrar")
	#echo "RESULTADO = $resultado"
}

##FUNCION
busca_respaldos () {
#1 = fecha
#2 = rest
#3 = main_db
#4 = pos_num
#5 = anio-mes
#6 = origen
#7 = archivo
#8 = $user
#9 = pass
rest_short=${2:1:4}
directorio_respaldos="/backup/logs/$main_db"
for archivos_respaldo in `ls $directorio_respaldos/log.$3.$rest_short.pos$4.$5.*`;

do
        echo "Encontrado respaldo = $archivos_respaldo"
	archivo_res="$(basename $archivos_respaldo)"
	cp $directorio_respaldos/$archivo_res $scripts/$main_db/
	gzip -d $scripts/$main_db/$archivo_res
	#mkdir /home/$3/rest/$2/logs/pos$4/$5
	tar -xvf $scripts/$main_db/${archivo_res%.gz} -C /
	rm $scripts/$main_db/${archivo_res%.gz}
	procesa_log $6 $7 $3 $8 $9
	#ls $archivos_respaldo
done
}



##Inicia iterar en todos los restaurantes....
#for r in $home/* ; do
        #echo "$r"
        #rest="$(basename $r)"
        rest=0$3
	resto="MX$rest"
        #echo "Este es el Rest   = $rest"
        if [ "${#rest}" -eq "5" ]
        then
##BORRA LA INFO ANTES DE INTENTAR SUBIR, aun si existe o no!
borra_info $1 $resto $main_db $user $pass
###---------------------------

directorio_logs="/home/$main_db/rest/$rest/logs"

for d in $directorio_logs/* ; do
    #echo "$d"
        POS="$(basename $d)"
	pos_num=${POS//[!0-9]/}
        origen=$directorio_logs/$POS/$anio-$mes
                if [ -f "$origen/$archivo" ];
                then
                        echo "Encontrado en: $origen/$archivo"
			procesa_log $origen $archivo $main_db $user $pass
		else
			echo "---> WARNING --->No se encontro en: $origen/$archivo"
			busca_respaldos $1 $rest $main_db $pos_num $anio-$mes $origen $archivo $user $pass
                fi;

done
else
	echo "Restaurante invalido... "; exit 1
fi
#done;

else #fin verificacion de Ruta home
echo "$home No existe o no es una ruta de franquicia valida..."; exit 1
fi;
