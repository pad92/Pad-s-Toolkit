#!/usr/bin/env sh
#
# Reference : http://git.depad.fr/pascal/pad-s-toolkit/raw/master/MySQL/backup_sql.sh

# === CONFIG ===
BCKDIR='/var/backup/mysql'
MYCNF='/etc/mysql/debian.cnf'
CNF='/etc/mysql/my.cnf'

BIN_DEPS='xz mysql mysqldump'
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
cp $CNF $DST/
for BDD in `mysql --defaults-file=$MYCNF --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
    f_log "* Processing BDD $BDD"
    mysql --defaults-file=$MYCNF --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`;" | awk -F"\t" '{ print $2 }' > $DST/$BDD-create.sql
    f_log "  > Export 'SHOW CREATE TABLE'"
    mysqldump --defaults-file=$MYCNF --routines --no-create-info --no-data --no-create-db --skip-opt $BDD > $DST/$BDD-routines.sql
    f_log "  > Exports Routines"
    for TABLE in `mysql --defaults-file=$MYCNF --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
        mkdir -p $DST/$BDD 2>/dev/null 1>&2
        chown mysql:mysql $DST/$BDD
        f_log "  ** Dump $BDD.$TABLE"
        mysqldump --defaults-file=$MYCNF --single-transaction $BDD $TABLE > "$DST"/"$BDD"/"$TABLE".sql
        if [ -f "$DST/$BDD/$TABLE.sql" ]; then
            f_log "  ** xz $BDD/$TABLE.txt in background"
            xz $DST/$BDD/$TABLE.sql &
        else
            f_log "  ** WARNING : $DST/$BDD/$TABLE.sql not found"
        fi
    done
done
f_log "** END **"
