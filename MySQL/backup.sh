#!/usr/bin/env sh

MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`

if [ -f $(dirname $0)"/backup.conf" ]; then
    . $(dirname $0)"/backup.conf"
    logger $(basename $0)' - '$$' - '$(dirname $0)'/backup.conf OK'
    DAYOFMONT=`date +%e`
    DATETODAY=$(date +%Y%m%d)
    if [ -f $MYCNF ]; then
        logger $(basename $0)' - '$$' - '$MYCNF' OK'

        DATE=$(date '+%Y%m%d')
        DATEOLD=$(date '+%Y%m%d –date ’1 weeks ago’')
        DST=$BCKDIR/$DATE
        DSTOLD=$BCKDIR/$DATEOLD

        if [ ! -d $DST ];  then mkdir $DST;      fi
        if [ -d $DSTOLD ]; then rm -fr  $DSTOLD; fi

        for BDD in $($MYSQL --defaults-file=$MYCNF --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"); do
            echo $BDD
            $MYSQL --defaults-file=$MYCNF --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`;" | cut -d" " -f2- > $DST/create-$BDD.sql
            for TABLE in $($MYSQL --defaults-file=$MYCNF --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log); do
                mkdir $DST/$BDD 2>/dev/null 1>&2
                $MYSQLDUMP --defaults-file=$MYCNF --opt $BDD $TABLE > $DST/$BDD/$TABLE.sql
            done
            if [ -d $DST/$BDD ]; then
                find $DST/$BDD -type d -empty -delete
                gzip -f $DST/$BDD/*.sql &
            fi
        done
    else
        logger $(basename $0)' - '$$' - '$MYCNF' KO'
        exit 0
    fi
else
    echo "Fichier de configuration " $(dirname $0)"/backup.conf inexistant"
    logger $(basename $0)' - '$$' - '$(dirname $0)'/backup.conf KO'
    exit 1
fi



