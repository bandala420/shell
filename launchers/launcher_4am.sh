#!/bin/bash
#Procesar archivos por rango de dias
#Autor: Daniel Clarks @ gpomonse 2021-02
#

scripts=/root/scripts_globales

#$scripts/limpieza/cierres_procesados_limpia.sh mcd_nb >/dev/null 2>&1
$scripts/limpieza/cierres_procesados_limpia.sh mcd_intermex >/dev/null 2>&1
$scripts/limpieza/cierres_procesados_limpia.sh mcd_grill >/dev/null 2>&1
$scripts/limpieza/cierres_procesados_limpia.sh mcd_jucegare >/dev/null 2>&1
$scripts/limpieza/cierres_procesados_limpia.sh mcd_gpomonse >/dev/null 2>&1
#$scripts/limpieza/cierres_procesados_limpia.sh mcd_cly >/dev/null 2>&1

#mcd_gpmonse
$scripts/actualizar_uso_ingredientes_diario/actualizar_uso_ingredientes_diario.sh mcd_gpomonse $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/variacion_total_inventarios_diario/launcher_variacion_total_inventarios_diario.sh mcd_gpomonse $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/uso_ingredientes_proyeccion/uso_ingredientes_proyeccion_launcher.sh mcd_gpomonse $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1

#mcd_nb
$scripts/data_migration_launcher/data_migration_launcher.sh mcd_nb >/dev/null 2>&1
$scripts/actualizar_uso_ingredientes_diario/actualizar_uso_ingredientes_diario.sh mcd_nb $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1
$scripts/variacion_total_inventarios_diario/launcher_variacion_total_inventarios_diario.sh mcd_nb $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1
$scripts/uso_ingredientes_proyeccion/uso_ingredientes_proyeccion_launcher.sh mcd_nb $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1

#mcd_cly
$scripts/data_migration_launcher/data_migration_launcher.sh mcd_cly >/dev/null 2>&1
$scripts/actualizar_uso_ingredientes_diario/actualizar_uso_ingredientes_diario.sh mcd_cly $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1
$scripts/variacion_total_inventarios_diario/launcher_variacion_total_inventarios_diario.sh mcd_cly $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/uso_ingredientes_proyeccion/uso_ingredientes_proyeccion_launcher.sh mcd_cly $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1

# mcd_intermex
$scripts/data_migration_launcher/data_migration_launcher.sh mcd_intermex >/dev/null 2>&1
$scripts/actualizar_uso_ingredientes_diario/actualizar_uso_ingredientes_diario.sh mcd_intermex $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/variacion_total_inventarios_diario/launcher_variacion_total_inventarios_diario.sh mcd_intermex $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/uso_ingredientes_proyeccion/uso_ingredientes_proyeccion_launcher.sh mcd_intermex $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1

#jucegare
$scripts/data_migration_launcher/data_migration_launcher.sh mcd_jucegare >/dev/null 2>&1
$scripts/actualizar_uso_ingredientes_diario/actualizar_uso_ingredientes_diario.sh mcd_jucegare $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1
$scripts/variacion_total_inventarios_diario/launcher_variacion_total_inventarios_diario.sh mcd_jucegare $(date  --date="1 days ago" +%Y-%m-%d)  >/dev/null 2>&1
$scripts/uso_ingredientes_proyeccion/uso_ingredientes_proyeccion_launcher.sh mcd_jucegare $(date  --date="1 days ago" +%Y-%m-%d) >/dev/null 2>&1


# Run posync files process
$scripts/posync/launcher_posync.sh &> /dev/null

# Clean reports folder
$scripts/limpieza/report_cleaning.sh &> /dev/null

# Update recipes costs
$scripts/prices/update_launcher.sh &> /dev/null

# Update items prices and last sale date
$scripts/prices/items_update_launcher.sh &> /dev/null

# Update wrins use information
$scripts/actualizar_uso_ingredientes_diario/last_sale_launcher.sh &> /dev/null

# Generate consolidated sales information
$scripts/cierres/generator_launcher.sh &> /dev/null

# Generate new items information
$scripts/cierres/items_launcher.sh &> /dev/null

#change of prices
origen="/root/scripts_globales/params"
for bd in `ls $origen`;
do
	completename="$(basename $bd)"
	name=${completename%.*}
	$scripts/cambioPrecios/save_change_prices.sh $name &> /dev/null
done