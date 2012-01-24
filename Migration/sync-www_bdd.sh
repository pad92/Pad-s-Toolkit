#!/usr/bin/env sh

REMOTE='oldserver.domain.ltd'

DIRS="/var/www/site1/
/var/www/site2/"

BDDS="bdd1
bdd2"

echo "$(date '+%D %H:%M:%S') * rsync"
for DIR in $DIRS
do
    echo "$(date '+%D %H:%M:%S') -- $DIR"
    if [ ! -d $DIR ]; then
        mkdir -p $DIR
    fi
    rsync --delete -au $REMOTE::migration$DIR $DIR
done

echo "$(date '+%D %H:%M:%S') * bbd"
for BDD in $BDDS
do
    echo "$(date '+%D %H:%M:%S') -- $BDD"
    mysql -B -e "DROP DATABASE IF EXISTS $BDD;"
    mysql -h $REMOTE --skip-column-names -B -e "SHOW CREATE DATABASE $BDD\G" | grep ^CREATE | mysql
    mysqldump -h $REMOTE $BDD | mysql $BDD
done
