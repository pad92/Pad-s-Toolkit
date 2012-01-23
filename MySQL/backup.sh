#!/usr/bin/env bash

BCKDIR='/var/backup/mysql'

DATE=$(date '+%Y%m%d')
DATEOLD=$(date '+%Y%m%d –date ’1 weeks ago’')
DST=$BCKDIR/$DATE

if [ ! -d $DST ];  then mkdir $DST;      fi
if [ -d $DSTOLD ]; then rm -fr  $DSTOLD; fi

for BDD in `mysql --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
    echo -ne $BDD
    mysql --skip-column-names -B -e "SHOW CREATE DATABASE $BDD;" | cut -d" " -f2- > $DST/create-$BDD.sql
    for TABLE in `mysql --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
        mkdir $DST/$BDD 2>/dev/null 1>&2
        mysqldump --opt $BDD $TABLE > $DST/$BDD/$TABLE.sql 
        echo -ne "."
    done
    gzip $DST/$BDD/*.sql &
    echo -ne "\r\n"
done
