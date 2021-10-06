#!/bin/bash
# -*- coding: utf-8 -*-
# Author: Daniel Bandala @ gpomonse 28-01-2021
# bash report_cleaning.sh

# Path variables
reportsPath=/var/www/html/generated/reports

# Cahnge to reports path and remove old files
cd $reportsPath || exit -1
for reportFolder in $(ls -d */); do
    find $reportFolder -type f -not -name "*.html" -mtime +2 -delete
done