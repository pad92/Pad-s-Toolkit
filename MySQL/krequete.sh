#!/usr/bin/env sh

MYCNF='/etc/mysql/debian.cnf'
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
    logger "$0 - $@"
    echo "$@"
}

# Kill select >= 5min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE INFO LIKE "SELECT%" and TIME >= "300"'); do
    f_log "* kill SELECT query $QUERY_ID"
    f_log $(mysql  --skip-column-names -B -e "SELECT Info FROM information_schema.processlist WHERE id = $QUERY_ID")
    mysqladmin kill $QUERY_ID
done

# Kill update >= 5min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE INFO LIKE "update%" and TIME >= "300"'); do
    f_log "* kill UPDATE query $QUERY_ID"
    f_log $(mysql  --skip-column-names -B -e "SELECT Info FROM information_schema.processlist WHERE id = $QUERY_ID")
    mysqladmin kill $QUERY_ID
done

# Kill sleep >= 1min
for QUERY_ID in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id FROM information_schema.processlist WHERE COMMAND LIKE "Sleep" and TIME >= "60"'); do
    f_log "* kill SLEEP query $QUERY_ID"
    mysqladmin kill $QUERY_ID
done
