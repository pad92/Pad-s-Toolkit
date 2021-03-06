#!/usr/bin/env sh

##
# Don't work with MySQL 4.x
# ( Use information_schema database )

MYCNF='/root/.my.cnf'
BIN_DEPS='mysql mysqladmin'

for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# === FUNCTION ===
f_log() {
    logger "$0 - $*"
    echo  "$*"
}

mysqladmin --defaults-extra-file=$MYCNF status 1>/dev/null 2>&1
if [ "$?" -ne "0" ]; then
    f_log "MySQL status unavailable, exiting"
    exit 1
else
    f_log $(mysqladmin --defaults-extra-file=$MYCNF status)
fi

## KILL ###
# Kill select >= 5min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE INFO LIKE "SELECT%" and TIME >= "300"'); do
    f_log "* kill SELECT query $QUERY_ID"
    f_log $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SELECT user,host,info FROM information_schema.processlist WHERE id = $QUERY_ID")
    mysqladmin --defaults-extra-file=$MYCNF kill $QUERY_ID
done

# Kill sleep >= 1min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE COMMAND LIKE "Sleep" and TIME >= "60"'); do
    f_log "* kill SLEEP query $QUERY_ID"
    mysqladmin --defaults-extra-file=$MYCNF kill $QUERY_ID
done

### LOG ###
# log update >= 5min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE INFO LIKE "update%" and TIME >= "300"'); do
    f_log "* UPDATE query $QUERY_ID >= 5min :"
    f_log $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SELECT user,host,info FROM information_schema.processlist WHERE id = $QUERY_ID")
done

# log insert >= 5min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE INFO LIKE "insert%" and TIME >= "300"'); do
    f_log "* INSERT query $QUERY_ID >= 5min"
    f_log $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SELECT user,host,info FROM information_schema.processlist WHERE id = $QUERY_ID")
done
