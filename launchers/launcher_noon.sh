#!/bin/bash
# -*- coding: utf-8 -*-
# Author: Daniel Bandala @ gpomonse ene 2021
# SCRIPT SE EJECUTA DIARIO A MEDIO DIA 12:00 PM

scripts=/root/scripts_globales
# Process inventario csv files
invScript=$scripts/migration/inventario/auto_inventario_db.sh
bash $invScript mcd_gpomonse &> /dev/null
bash $invScript mcd_intermex &> /dev/null
bash $invScript mcd_jucegare &> /dev/null
bash $invScript mcd_nb &> /dev/null
bash $invScript mcd_cly &> /dev/null
# Process desperdicio csv files
despScript=$scripts/migration/desperdicio/auto_desperdicio_db.sh
bash $despScript mcd_gpomonse &> /dev/null
bash $despScript mcd_intermex &> /dev/null
bash $despScript mcd_jucegare &> /dev/null
bash $despScript mcd_nb &> /dev/null
bash $despScript mcd_cly &> /dev/null
# Process StoreDb files
storedbScript=$scripts/xml_storedb/auto_storedb.sh
bash $storedbScript mcd_gpomonse &> /dev/null
bash $storedbScript mcd_intermex &> /dev/null
bash $storedbScript mcd_jucegare &> /dev/null
bash $storedbScript mcd_nb &> /dev/null
bash $storedbScript mcd_cly &> /dev/null