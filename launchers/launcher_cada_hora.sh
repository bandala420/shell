#!/bin/bash
#Launcher cada hora X  24 horas
#Autor: daclark@gpomonse 2021-07

scripts=/root/scripts_globales

# KVS_LOG

#Cicla para todaslas DB
origen="/root/scripts_globales/params"
for bd in `ls $origen`;
do
        completename="$(basename $bd)"
        main_db=${completename%.*}
        $scripts/kvs/do_kvs.sh $(date +%Y-%m-%d)  $main_db &> /dev/null
done




