#!/usr/bin/env sh

MYCNF='/etc/mysql/debian.cnf'
BIN_DEPS='mysql watch'

for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

watch "mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e 'SELECT id,user,host,db,command,time,state FROM information_schema.processlist'"
