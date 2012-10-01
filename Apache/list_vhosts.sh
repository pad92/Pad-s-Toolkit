#!/usr/bin/env sh

##
# prerequisites
# * dig : dnsutils

VHOSTS=$(egrep -h -i 'serveralias|servername' /etc/apache2/sites-enabled/* | sed 's/ServerName//gI' | sed 's/ServerAlias//gI' | sed ':a;N;$!ba;s/ /\n/g' | sed 's/\t//g' |grep -v "^$" | sort)

for VHOST in $VHOSTS; do
    VHOST_A=$(dig +short A $VHOST @8.8.8.8 | sed ':a;N;$!ba;s/\n/ /g')
    echo "$VHOST : $VHOST_A"
done
