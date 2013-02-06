#!/usr/bin/env sh

mysql --skip-column-names -B -e "select user,host from mysql.user" | awk '{ print "SHOW GRANTS FOR \x27"$1"\x27@\x27"$2"\x27 ;"}' > /tmp/grants.sql | mysql  --skip-column-names -B < /tmp/grants.sql ; rm /tmp/grants.sql
