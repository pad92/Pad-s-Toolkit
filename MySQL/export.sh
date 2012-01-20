#!/usr/bin/env bash

DST='/var/backup/mysql/dump'
for bdd in `mysql --skip-column-names -B -e "show databases;" | egrep -v "^information_schema$|^mysql$"`; do
        echo -ne $bdd
        mysql --skip-column-names -B -e "SHOW CREATE DATABASE $bdd;" | cut -d" " -f2- > $DST/create-$bdd.sql
        for table in `mysql --skip-column-names -B $bdd -e "show tables;"`; do
                mkdir $DST/$bdd 2>/dev/null 1>&2
                chown mysql:mysql $DST/$bdd
                echo -ne "."
                mysqldump -T $DST/$bdd/ $bdd $table
        done
        echo -ne "\r\n"
done
