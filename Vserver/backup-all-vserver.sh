#!/usr/bin/env sh

##
# For mysql server, create /vservers/'$HOST'/etc/mysql/backup.cnf with login/pass/host informations

DOW=$(date +%w)
BIN_DEPS='rsync bzip2 mysql mysqldump'
RSYNC='rsync -aupt --delete'

# CHECKS
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# BACKUP RSYNC des /etc de tous les vservers present dans le fstab
for HOST in $(cat /etc/fstab  | grep -v ^# | grep vservers | cut -d'/' -f4); do
    if [ ! -d "/var/backup/$HOST/$DOW/etc" ]; then
        mkdir -p /var/backup/$HOST/$DOW/etc
    fi
    # Backup /etc
    $RSYNC /vservers/$HOST/etc/ /var/backup/$HOST/$DOW/etc/
    # Backup de /var/www si existant
    if [ -d "/vservers/'$HOST'/var/www" ]; then
        if [ ! -d "/var/backup/$HOST/$DOW/var/www" ]; then
            mkdir -p /var/backup/$HOST/$DOW/var/www
        fi
        $RSYNC /vservers/'$HOST'/var/www /var/backup/$HOST/$DOW/var/www
    fi
    # Backup de MySQL si socket existante (/vservers/$HOST/var/run/mysqld/mysqld.sock)
    if [ -S "/vservers/'$HOST'/var/run/mysqld/mysqld.sock" ]; then
        MYCNF='/vservers/'$HOST'/etc/mysql/backup.cnf'
        MYSQL_DST='/var/backup/'$HOST'/'$DOW'/mysql'
        if [ ! -d "$MYSQL_DST" ]; then
            mkdir -p $MYSQL_DST
        fi
        for BDD in `mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"`; do
            mysql --defaults-extra-file=$MYCNF --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`;" | cut -d" " -f2- > $MYSQL_DST/create-$BDD.sql
            for TABLE in `mysql --defaults-extra-file=$MYCNF --skip-column-names -B $BDD -e "SHOW TABLES;" | grep -v slow_log | grep -v general_log`; do
                mkdir $MYSQL_DST/$BDD 2>/dev/null 1>&2
                mysqldump --defaults-file=$MYCNF --opt $BDD $TABLE > $MYSQL_DST/$BDD/$TABLE.sql
                bzip2 -f $MYSQL_DST/$BDD/$TABLE.sql &
            done
        done
    fi
done
