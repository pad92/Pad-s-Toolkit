#!/usr/bin/env sh


if [ "$#" -eq "3" ] && [ -f $1 ]; then
    TMP_FILE=`tempfile 2>/dev/null` || TMP_FILE=/tmp/test$$
    trap "rm -f $TMP_FILE" 0 1 2 5 15
    SERVER_LIST=$1
    USER_NAME=$2
    USER_PASSWD=$3

    echo "echo $USER_PASSWD | passwd $USER_NAME"    > $TMP_FILE

    for SRV_NAME in `cat $1`; do
        echo "* Send to $SRV_NAME"
        scp $fichtemp $SRV_NAME:/tmp/.do
        echo "* Exec on $SRV_NAME"
        ssh $SRV_NAME 'sh /tmp/.do ; rm /tmp/.do'
    done

else
    echo "Usage : `basename "$0"` [Servers List] [user] [password]" 
fi
