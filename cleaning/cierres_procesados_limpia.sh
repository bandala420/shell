#!/bin/bash
#Procesar todos los  CSV de cierre importados de matrix, destino tabla: cierre
#Objetivo: facturacion global y migraciones a OD
#Autor: daclark@gpomonse 2021-02
#variables solo main_db que debe ser igual a el home
#Ej.  ./do_cierres_import.sh mcd_gpomonse


main_db=$1
home="/home/$main_db/rest"






for r in $home/* ; do
        #echo "$r"
        rest="$(basename $r)"
        rest=${r//[!0-9]/}
        #echo "Este es el Rest   = $rest"
        if [ "${#rest}" -eq "5" ]
        then
		origen_csv="$home/$rest/csv/cierre"
        	if [ -d $origen_csv/procesados ]; then
			rm $origen_csv/procesados/V*$rest*.csv*
        	fi
	##fin ciclo rest
	fi
done



