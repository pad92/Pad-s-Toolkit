#!/usr/bin/env bash

for requete in $(mysql INFORMATION_SCHEMA -B -e'select id from PROCESSLIST where INFO like "select%" and TIME >= "300"'| grep -v id); do
	/usr/bin/mysqladmin kill $requete
	echo -ne "s"
done

for requete in $(mysql INFORMATION_SCHEMA -B -e'select id from PROCESSLIST where INFO like "update%" and TIME >= "300"'| grep -v id); do
	/usr/bin/mysqladmin kill $requete
	echo -ne "u"
done

for requete in $(mysql INFORMATION_SCHEMA -B -e'select id from PROCESSLIST where COMMAND like "Sleep" and TIME >= "60"'| grep -v id); do
	/usr/bin/mysqladmin kill $requete
	echo -ne "s"
done
