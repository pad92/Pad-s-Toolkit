#!/usr/bin/env sh

PGUSER='postgres'
DST=$(echo "/var/backups/"$(hostname)"/postgres/"$(date +"%H")/)

if [ ! -d "$DST" ]; then
    mkdir -p $DST;
    chown $PGUSER $DST
fi

for DB in $(/usr/bin/psql -l | grep postgres | awk '{ print $1 }' | grep -v ^\|); do 
    /usr/bin/pg_dump -Ft -b $DB > $DST$DB.tar
done
