#!/usr/bin/env bash

BCKDIR='/var/backup/mysql'
MYCNF='/etc/mysql/debian.cnf'

BIN_DEPS='mysql mysqldump'
DATE=$(date '+%Y%m%d')
DATEOLD=$(date '+%Y%m%d –date ’1 weeks ago’')
DST=$BCKDIR/$DATE

# CHECKS
for BIN in $BIN_DEPS; do
    which -s $BIN
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

if [ ! -d $DST ];  then mkdir $DST;      fi
if [ -d $DSTOLD ]; then rm -fr  $DSTOLD; fi

# CORE
for BDD in `mysql --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
    echo -ne $BDD
    mysql --skip-column-names -B -e "SHOW CREATE DATABASE $BDD;" | cut -d" " -f2- > $DST/create-$BDD.sql
    for TABLE in `mysql --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
        mkdir $DST/$BDD 2>/dev/null 1>&2
        mysqldump --defaults-file=$MYCNF --opt $BDD $TABLE > $DST/$BDD/$TABLE.sql
        echo -ne "."
    done
    gzip $DST/$BDD/*.sql &
    echo -ne "\r\n"
done
