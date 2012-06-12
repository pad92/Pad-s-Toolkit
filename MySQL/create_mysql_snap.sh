#!/usr/bin/env sh

### TO DELETE
echo "* check lv path"
echo "* check if you have 3Go free in pv"
exit 1

### CORE ###
mysql -e "FLUSH TABLES WITH READ LOCK; SHOW MASTER STATUS; system lvcreate -s -L 3G -n snap /dev/system/var_lib_mysql; UNLOCK TABLES;"
mysql -e "UNLOCK TABLES;"
echo ""
echo "To remove the snap :"
echo "lvremove /dev/system/snap"
