#!/usr/bin/env sh


### VARIABLES ###
LV_MYSQL="/dev/system/var_lib_mysql"
DATE=$(date '+%Y%m%d')

### TO DELETE
echo "* check configuration file !!!"
echo "* check if you have 1Go free in pv"
echo "end delete this line ;)"
exit 1


### CORE ###
mysql -e "FLUSH TABLES WITH READ LOCK; SHOW MASTER STATUS;" && lvcreate -s -L 1G -n snap-$DATE $LV_MYSQL
mysql -e "UNLOCK TABLES;"
echo ""
echo "To remove the snap :"
echo "lvremove /dev/system/snap-$DATE"
