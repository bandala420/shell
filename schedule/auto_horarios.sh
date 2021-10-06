#!/bin/bash
# -*- coding: utf-8 -*-
# Author: Daniel Bandala @ GPOMONSE 02-04-2021
# bash auto_horarios.sh mcd_gpomonse

# Input variable
mainRoot=$1
if [[ -z "$mainRoot" ]];then
    echo Faltan argumentos
    exit -1
fi

# Run integrity script for each restaurant
cd /home
if [[ -d "$mainRoot/rest" ]]; then
    cd /home/$mainRoot/rest || exit -1
    for restaurant in $(ls -d *); do
        bash /root/scripts_globales/horarios/horarios_empleados.sh $mainRoot $restaurant
    done
fi