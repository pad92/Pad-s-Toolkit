#!/usr/bin/env sh

BCKDIR='/var/backup/mysql'
MYCNF='/etc/mysql/debian.cnf'

BIN_DEPS='bzip2 mysql mysqldump'
DATE=$(date '+%Y%m%d')
DATEOLD=$(date '+%Y%m%d –date ’1 weeks ago’')
DST=$BCKDIR/$DATE
DSTOLD=$BCKDIR/$DATEOLD

# CHECKS
for BIN in $BIN_DEPS; do
    which $BIN 2>/dev/null 1>&2
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

if [ ! -d "$DST" ]; then
    mkdir $DST
fi
if [ -d "$DSTOLD" ]; then
    rm -fr  $DSTOLD
fi

# CORE
for BDD in `mysql --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$|^lost+found$"`; do
    echo -ne $BDD
    mysql --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`;" | cut -d" " -f2- > $DST/create-$BDD.sql
    for TABLE in `mysql --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
        if [ ! -d $DST/$BDD ]; then
            mkdir $DST/$BDD
            chown mysql $DST/$BDD
        fi
        mkdir $DST/$BDD 2>/dev/null 1>&2
        mysqldump --defaults-file=$MYCNF --opt $BDD $TABLE -T $DST/$BDD/ &
        echo -ne "."
    done
    echo -ne "\r\n"
done

# WAITING
echo "waiting "
while :
do
    MYSQLDUMP_LEFT=$(ps a | grep mysqldump | grep -v grep | wc -l )
    if [ "$MYSQLDUMP_LEFT" -eq "0" ]; then
        find $DST -empty -delete
        echo "Compressing"
        for TXT in `find $DST -iname "*.txt" -ls`; do
            bzip2 $TXT &
        done

        # WAITING
        echo "compressing "
        while :
        do
            MYSQLDUMP_LEFT=$(ps a | grep bzip2 | grep -v grep | wc -l )
            if [ "$MYSQLDUMP_LEFT" -eq "0" ]; then
                echo -ne "\r\n"
            done
            exit 0
        else
            sleep 1
            echo -ne "."
        fi
    done
    echo -ne "\r\n"
done
exit 0
    else
        sleep 1
        echo -ne "."
    fi
done
