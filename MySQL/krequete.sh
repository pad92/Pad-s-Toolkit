#!env bash

for QUERY in $(mysql INFORMATION_SCHEMA --skip-column-names -B -e'select id from PROCESSLIST where INFO like "select%" and TIME >= "300"'); do
	mysqladmin kill $QUERY
	echo -ne "s"
done

for QUERY in $(mysql INFORMATION_SCHEMA --skip-column-names -B -e'select id from PROCESSLIST where INFO like "update%" and TIME >= "300"'); do
	mysqladmin kill $QUERY
	echo -ne "u"
done

for QUERY in $(mysql INFORMATION_SCHEMA --skip-column-names -B -e'select id from PROCESSLIST where COMMAND like "Sleep" and TIME >= "60"'); do
	mysqladmin kill $QUERY
	echo -ne "s"
done
