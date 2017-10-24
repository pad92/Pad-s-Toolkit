#!/bin/sh
#
# Reference : https://git.depad.fr/depad/pad-s-toolkit/raw/master/MySQL/backup_mysql.sh
#
# Install : wget https://git.depad.fr/depad/pad-s-toolkit/raw/master/MySQL/backup_mysql.sh -O /usr/local/bin/backup_mysql.sh && chmod +x /usr/local/bin/backup_mysql.sh

# === CONFIG ===
BCKDIR='/var/backups/mysql'         # backup destination
MYCNF='/root/.my.cnf'               # mysql account for dumps
CNF='/etc/mysql/'                   # mysql configuration
#MYSQL_PARAM='--set-gtid-purged=OFF' # MySQL > 5.6
MYSQL_PARAM=''                      # MySQL < 5.6
DUMP_SQL=true                       # sql dump table (default)
DUMP_CSV=false                      # csv dump tables (for big tables)

BIN_DEPS='xz mysql mysqldump'                    # binaries
DATE=$(date '+%Y.%m.%d_%H')                      # now, for internal usage
DATEOLD=$(date --date='1 week ago' +%Y.%m.%d_%H) # old backup to delete, change time here
DST=${BCKDIR}/${DATE}                            # target directory
DSTOLD=${BCKDIR}/${DATEOLD}                      # old backup to delete

# === CHECKS ===
for BIN in ${BIN_DEPS}; do
    which ${BIN} 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: ${BIN}"
        exit 1
    fi
done

if [ ! -d "${DST}" ];  then mkdir -p ${DST};   fi
if [ -d "${DSTOLD}" ]; then rm -fr  ${DSTOLD}; fi

# === FUNCTION ===
f_log() {
    logger "$0 - $@"
}

# === CORE ===
f_log "** START **"
tar cPJf ${DST}/etc_mysql.tar.xz ${CNF}/
{
    for BDD in `mysql --defaults-file=${MYCNF} --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
        f_log "* Processing BDD ${BDD}"
        mysql --defaults-file=${MYCNF} --skip-column-names -B -e "SHOW CREATE DATABASE \`${BDD}\`;" | awk -F"\t" '{ print $2 }' > ${DST}/${BDD}-create.sql
        f_log "  > Export 'SHOW CREATE TABLE'"
        mysqldump --defaults-file=${MYCNF} ${MYSQL_PARAM} --routines --no-create-info --no-data --no-create-db --skip-opt ${BDD} > ${DST}/${BDD}-routines.sql
        f_log "  > Exports Routines"
        for TABLE in `mysql --defaults-file=${MYCNF} --skip-column-names -B ${BDD} -e "SHOW full tables where Table_Type = 'BASE TABLE';" | cut -f1 -s`; do
            mkdir -p ${DST}/${BDD} 2>/dev/null 1>&2
            chown mysql:mysql ${DST}/${BDD}
            f_log "  ** Dump ${BDD}.${TABLE}"
            # SQL Dump
            if [ $DUMP_SQL = true ]; then
              mysqldump --defaults-file=${MYCNF} ${MYSQL_PARAM} --single-transaction ${BDD} ${TABLE} > "${DST}"/"${BDD}"/"${TABLE}".sql
              if [ -f "${DST}/${BDD}/${TABLE}.sql" ]; then
                  f_log "  ** xz ${BDD}/${TABLE}.txt in background"
                  xz ${DST}/${BDD}/${TABLE}.sql &
              else
                  f_log "  ** WARNING : ${DST}/${BDD}/${TABLE}.sql not found"
              fi
            fi
            # CSV Dump
            if [ $DUMP_CSV = true ]; then
              MYSQL_SECURE_DIR=`mysql -N -s -e 'select @@secure_file_priv'`
              if [ -d "${MYSQL_SECURE_DIR}" ]; then
                  DST=${MYSQL_SECURE_DIR}/${DATE}
                  DSTOLD=${MYSQL_SECURE_DIR}/${DATEOLD}
                  if [ ! -d "${DST}" ];  then mkdir -p ${DST};   fi
                  if [ -d "${DSTOLD}" ]; then rm -fr  ${DSTOLD}; fi
              fi
              mysqldump --defaults-file=$MYCNF -T $DST/$BDD/ $BDD $TABLE
              if [ -f "$DST/$BDD/$TABLE.sql" ]; then
                  chmod 750 $DST/$BDD/$TABLE.sql
                  chown root:root $DST/$BDD/$TABLE.sql
                  f_log "  ** set perm on $BDD/$TABLE.sql"
              else
                  f_log "  ** WARNING : $DST/$BDD/$TABLE.sql not found"
              fi
              if [ -f "$DST/$BDD/$TABLE.txt" ]; then
                  f_log "  ** xz $BDD/$TABLE.txt in background"
                  xz $DST/$BDD/$TABLE.txt &
              else
                  f_log "  ** WARNING : $DST/$BDD/$TABLE.txt not found"
              fi
            fi
        done
    done
} | cat
f_log "** END **"
