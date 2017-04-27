#!/bin/sh

DIR='/tmp'

DATE=`date +%Y%m%d`
INV_FILE="inventaire.${DATE}.csv"

rm -fr "$DIR/*$DATE.*.inv"

echo 'Hostname;Paquet;Version' > $INV_FILE

for i in $(grep '^172.21' /etc/hosts | awk '{print $NF}' | sort | uniq ); do
    echo $i
    ssh $i 'rpm -qa --queryformat "%{NAME};%{VERSION}\n"'           1> $DIR/$i.$DATE.rpm.inv  2>/dev/null
    ssh $i "dpkg-query -W -f='\${binary:Package};\${Version}\n'"    1> $DIR/$i.$DATE.dpkg.inv 2>/dev/null
    for PACKAGE in $( cat $DIR/$i.$DATE.*.inv); do
        echo "$i;$PACKAGE" >> $DIR/$INV_FILE
    done
    rm -fr $DIR/$i.$DATE.rpm.inv $DIR/$i.$DATE.dpkg.inv
done

echo "done : $DIR/$INV_FILE"
