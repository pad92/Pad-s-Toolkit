#!/usr/bin/env sh

# === CONFIG ===
DIR_PWD=$(pwd)
BIN_DEPS='zcat mysql'
MYCNF='/etc/mysql/debian.cnf'

# === CHECKS ===
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# check rundir
if [ "$(ls -1 $DIR_PWD/*create.sql 2>/dev/null | wc -l)" -le "0" ]; then
    echo Your must run script from backup directory
fi

echo "create databases"
# Create databases
for DB_CREATE in $(ls -1 $DIR_PWD/*create.sql); do
    if [ -f "$i" ]; then
        mysql --defaults-extra-file=$MYCNF < $DB_CREATE 2>/dev/null
    fi
done

echo "import tables"
# Import tables
for DATABASES in $( ls -d $DIR_PWD/*/ | awk -F"/" '{ print $(NF-1) }'); do
    zcat $DIR_PWD/$DATABASES/*.gz | mysql --defaults-extra-file=$MYCNF $DATABASES
done

echo "import routines"
# Import runtimes
for i in $(ls -1 $DIR_PWD/*routines.sql); do
    if [ -f "$i" ]; then
        mysql --defaults-extra-file=$MYCNF < $i 2>/dev/null
    fi
done

mysql --defaults-extra-file=$MYCNF -e "flush privileges;"
