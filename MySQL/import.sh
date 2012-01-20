#!/usr/bin/env bash

SRC='/var/backup/mysql'

for BDD in `ls -1 $SRC | grep -v sql`; do
        echo -ne $BDD
        for TABLE in `ls -1 $SRC/$BDD | awk -F. '{print $1}' | sort | uniq`; do
                mysql $BDD -e " SET foreign_key_checks = 0;
                                SOURCE $SRC/$BDD/$TABLE.sql;
                                LOAD DATA INFILE '$SRC/$BDD/$TABLE.txt'
                                INTO TABLE $TABLE;
                                SET foreign_key_checks = 1;"
                mysql $BDD -e "ALTER TABLE $TABLE ENGINE=InnoDB;" 1>/dev/null 2>&1 &
                echo -ne "."
        done
        echo -ne "\r\n"
done
