#!/usr/bin/env sh

######################
#### ONFIGURATION ####
######################

REMOTE='serveur.prod.local'

## pour synchroniser quelque dossier :
DIRS="/var/www/site1/
/var/www/site2/
/var/www/site3/"

## pour synchroniser tous les DocumentRoots :
# DIRS=$(grep DocumentRoot /etc/apache2/sites-enabled/* | awk '{print $3}' | sed 's!/$!!' | sed 's!$!/!')

## pour synchroniser quelque BDD :
BDDS="bdd1
bdd2
bdd3"

## pour synchroniser toutes les BDD (sauf les BDD systeme)
#BDDS=$("show databases;" | egrep -v "information_schema|performance_schema|lost\+found|mysql")

##############
#### CORE ####
##############

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
    echo  -n "$(date '+%D %H:%M:%S') -- $BDD : drop"
    mysql -B -e "DROP DATABASE IF EXISTS \`$BDD\`;"
    echo -n ", create"
    mysql -h $REMOTE --skip-column-names -B -e "SHOW CREATE DATABASE \`$BDD\`\G" | grep ^CREATE | mysql
    echo -n ", import"
    mysqldump -h $REMOTE $BDD | mysql $BDD
    echo -n ".\r\n"
done


## Display all grants
# mysql -h $REMOTE --skip-column-names -B -e "select user,host from mysql.user" | awk '{print "show grants for \x27"$1"\x27@\x27"$2"\x27;"}'  | mysql -h $REMOTE --skip-column-names -B
