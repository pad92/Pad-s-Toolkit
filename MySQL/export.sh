#!/usr/bin/env bash

DST='/var/backup/mysql/dump'
BIN_DEPS='mysql mysqldump cut egrep'

# CHECKS
for BIN in $BIN_DEPS; do
    which -s $BIN
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

#CORE
for BDD in `mysql --skip-column-names -B -e "show databases;" | egrep -v "^information_schema$|^mysql$"`; do
    echo -ne $BDD
    mysql --skip-column-names -B -e "SHOW CREATE DATABASE $BDD;" | cut -d" " -f2- > $DST/create-$BDD.sql
    for table in `mysql --skip-column-names -B $BDD -e "show tables;"`; do
        mkdir $DST/$BDD 2>/dev/null 1>&2
        chown mysql:mysql $DST/$BDD
        echo -ne "."
        mysqldump -T $DST/$BDD/ $BDD $table
    done
    echo -ne "\r\n"
done
