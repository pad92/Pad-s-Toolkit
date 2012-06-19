#!/usr/bin/env sh

MYCNF='/root/.my.cnf'
BIN_DEPS='mysql'

# CHECKS
for BIN in $BIN_DEPS; do
    which $BIN
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# CORE
for TABLE in $(mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('performance_schema','information_schema','mysql') AND engine = 'MyISAM' ORDER BY table_schema;" | awk '{print $1"."$2}'); do
    echo $TABLE
    mysql --defaults-extra-file=$MYCNF -B -e "ALTER TABLE $TABLE ENGINE=InnoDB;"
done
