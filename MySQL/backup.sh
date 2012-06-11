#!/usr/bin/env sh

# === CONFIG ===
BCKDIR='/var/backup/mysql'
MYCNF='/etc/mysql/debian.cnf'

BIN_DEPS='bzip2 mysql mysqldump'
DATE=$(date '+%Y.%m.%d')
DATEOLD=$(date --date='1 week ago' +%Y.%m.%d)
DST=$BCKDIR/$DATE
DSTOLD=$BCKDIR/$DATEOLD

# === CHECKS ===
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done


if [ ! -d "$DST" ];  then mkdir -p $DST;   fi
if [ -d "$DSTOLD" ]; then rm -fr  $DSTOLD; fi

# === FUNCTION ===
f_log() {
    logger "$0 - $@"
}

# === CORE ===
f_log "** START **"
for BDD in `mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
    f_log "* Processing BDD $BDD"
    mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`;" | cut -d" " -f2- > $DST/$BDD-create.sql
    f_log "  > Export 'SHOW CREATE TABLE'"
    mysqldump --routines --no-create-info --no-data --no-create-db --skip-opt $BDD > $DST/$BDD-routines.sql
    f_log "  > Exports Routines"
    for TABLE in `mysql --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
        mkdir -p $DST/$BDD 2>/dev/null 1>&2
        chown mysql:mysql $DST/$BDD
        f_log "  ** Dump $BDD.$TABLE"
        mysqldump --defaults-file=$MYCNF -T $DST/$BDD/ $BDD $TABLE
        f_log "  ** bzip2 $BDD.$TABLE in background"
        chmod 750 $DST/$BDD/$TABLE.*; chown root:root $DST/$BDD/$TABLE.*; bzip2 $DST/$BDD/$TABLE.txt &
    done
done
f_log "** END **"
