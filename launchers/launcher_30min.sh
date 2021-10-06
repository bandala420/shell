#!/bin/bash
#Procesar archivos por rango de dias
#Autor: Daniel Clarks @ gpomonse 2021-02

scripts=/root/scripts_globales
#echo "INICIO = $(date)" >> /root/logs/seg.log
# LOGS
$scripts/logs_pos/procesa_log.sh mcd_nb &> /dev/null
$scripts/logs_pos/procesa_log.sh mcd_gpomonse &> /dev/null
$scripts/logs_pos/procesa_log.sh mcd_intermex &> /dev/null
$scripts/logs_pos/procesa_log.sh mcd_jucegare &> /dev/null
$scripts/logs_pos/procesa_log.sh mcd_cly &> /dev/null
# TPA
$scripts/tpa_pos/procesa_tpa.sh mcd_nb &> /dev/null
$scripts/tpa_pos/procesa_tpa.sh mcd_gpomonse &> /dev/null
$scripts/tpa_pos/procesa_tpa.sh mcd_intermex &> /dev/null
$scripts/tpa_pos/procesa_tpa.sh mcd_jucegare &> /dev/null
$scripts/tpa_pos/procesa_tpa.sh mcd_cly &> /dev/null
# CIERRES
$scripts/cierres_import/do_cierres_import.sh mcd_nb &> /dev/null
$scripts/cierres_import/do_cierres_import.sh mcd_intermex &> /dev/null
$scripts/cierres_import/do_cierres_import.sh mcd_gpomonse &> /dev/null
$scripts/cierres_import/do_cierres_import.sh mcd_jucegare &> /dev/null
$scripts/cierres_import/do_cierres_import.sh mcd_cly &> /dev/null
# CORTES
$scripts/xml_cortes/script_invocacion.sh mcd_gpomonse &> /dev/null
$scripts/xml_cortes/script_invocacion.sh mcd_intermex &> /dev/null
$scripts/xml_cortes/script_invocacion.sh mcd_jucegare &> /dev/null
$scripts/xml_cortes/script_invocacion.sh mcd_cly &> /dev/null
$scripts/xml_cortes/script_invocacion.sh mcd_nb &> /dev/null
# SKIMS
$scripts/xml_skims/script_invocacion.sh mcd_gpomonse &> /dev/null
$scripts/xml_skims/script_invocacion.sh mcd_intermex &> /dev/null
$scripts/xml_skims/script_invocacion.sh mcd_jucegare &> /dev/null
$scripts/xml_skims/script_invocacion.sh mcd_cly &> /dev/null
$scripts/xml_skims/script_invocacion.sh mcd_nb &> /dev/null
# SCHEDULE
$scripts/horarios/auto_horarios.sh mcd_gpomonse &> /dev/null
$scripts/horarios/auto_horarios.sh mcd_intermex &> /dev/null
$scripts/horarios/auto_horarios.sh mcd_jucegare &> /dev/null
$scripts/horarios/auto_horarios.sh mcd_cly &> /dev/null
$scripts/horarios/auto_horarios.sh mcd_nb &> /dev/null
# SORT XML FILES
$scripts/posync/files_sorting.sh mcd_gpomonse &> /dev/null
$scripts/posync/files_sorting.sh mcd_intermex &> /dev/null
$scripts/posync/files_sorting.sh mcd_jucegare &> /dev/null
$scripts/posync/files_sorting.sh mcd_cly &> /dev/null
$scripts/posync/files_sorting.sh mcd_nb &> /dev/null
# SALES INFORMATION
$scripts/cierres/fast_generator_launcher.sh &> /dev/null

# PMIX_DIARIO
main_db=('mcd_gpomonse' 'mcd_nb' 'mcd_cly' 'mcd_intermex' 'mcd_jucegare')
for db in "${main_db[@]}"
do
    $scripts/pmix_diario/launcher_pmix_diario.sh $db $(date  --date="1 days ago" +%Y-%m-%d) &> /dev/null
done