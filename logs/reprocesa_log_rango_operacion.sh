#!/bin/bash
#Procesar archivos por rango de dias
#Autor: dackark@gpomonse 2021-04
#reprocesa logs por rango de TODOS LOS REST DE LA OPERACION
#BORRA LA INFO AUN SI NO HAY LOGS CON QUE SUSTITUIRLO
#
#
#./reprocesa_log_rango.sh  2018-12-12 2018-12-20  mcd_gpomonse

scripts=/root/scripts_globales/

echo "Fecha inicio = $1"
echo "Fecha final = $2"
echo "Franquicia = $3"



fecha_inicio=$(date -I -d "$1") || exit -1
fecha_final=$(date -I -d "$2")     || exit -1

read -p "Desea ordenar previamente los archivo LOG? esto asegura el proceso! " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[YySs]$ ]]
then
    $scripts/ordenar/logordenapos.sh $3
	clear
	echo "----------------Ordenado terminado INICIANDO----------------"
else
	clear
	echo "----------------INICIANDO sin ordenamiento previo----------------"
fi




d="$fecha_inicio"
while [ "$(date -d "$d" +%Y%m%d)" -le "$(date -d "$fecha_final" +%Y%m%d)" ]; do 
  echo $d
	$scripts/logs_pos/reprocesa_log_dia_operacion.sh $d $3
	#$scripts/xml_pmix/procesador_xml_pmix_nuevo.sh $d $3
  d=$(date -I -d "$d + 1 day")
done
