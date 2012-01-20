#!/usr/bin/env bash

for TABLE in `mysql --skip-column-names -B -e "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('performance_schema','information_schema','mysql') AND engine = 'MyISAM' ORDER BY table_schema;" | awk '{print $1"."$2}'`; do
    mysql -e "ALTER TABLE $TABLE ENGINE=InnoDB;"
    echo -ne "."
done
echo -ne "\r\n"
