#!/bin/bash
#Launcher cada hora X  24 horas
#Autor: daclark@gpomonse 2021-07

scripts=/root/scripts_globales

#Cicla para todaslas DB
origen="/root/scripts_globales/params"
for bd in `ls $origen`;
do
       completename="$(basename $bd)"
       main_db=${completename%.*}
       # $scripts/kvs/do_kvs.sh $(date +%Y-%m-%d)  $main_db &> /dev/null

       # Revision y reprocesamiento de variacion_total_inventarios_diario
       $scripts/variacion_total_inventarios_diario/launcher_variacion_total_revision.sh $main_db $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1
done