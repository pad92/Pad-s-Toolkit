#!/usr/bin/env sh

REMOTE='serveur.prod.local'

DIRS="/var/www/site1/
/var/www/site2/
/var/www/site3/"

BDDS="bdd1
bdd2
bdd3"

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
    echo "$(date '+%D %H:%M:%S') -- $BDD : Drop"
    mysql -B -e "DROP DATABASE IF EXISTS \`$BDD\`;"
    echo "$(date '+%D %H:%M:%S') -- $BDD : Create"
    mysql -h $REMOTE --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`\G" | grep ^CREATE | mysql
    echo "$(date '+%D %H:%M:%S') -- $BDD : Import"
    mysqldump -h $REMOTE $BDD | mysql $BDD
done


## Display all grants
# mysql -h $REMOTE --skip-column-names -B -e "select user,host from mysql.user" | awk '{print "show grants for \x27"$1"\x27@\x27"$2"\x27;"}'  | mysql -h $REMOTE --skip-column-names -B
