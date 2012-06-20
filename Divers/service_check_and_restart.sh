#!/usr/bin/env sh

# === CONFIGURATION ===
URL='http://url/to/check'
ERROR_LIST='ERR_LIST
ON PER LINE'
CURL_OPT='-s --connect-timeout 3 --retry 2 --retry-delay 1'
SERVICE_RESTART='/etc/init.d/apache'
TMP_FILE='/tmp/check_apache'

# === FUNCTION ===
f_log() {
    logger "$0 - $*"
    echo  "$*"
}

# === CHECKS ===
# Binaires
BIN_DEPS='curl'
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# === DO ===

curl $CURL_OPT -o $TMP_FILE $URL
RETVAL=$?

if [ $RETVAL = 0 ]; then
    for ERROR in $ERROR_LIST; do
        grep -q $ERROR $TMP_FILE
        if [[ $? -eq 0 ]] ; then
            f_log $(grep $ERROR $TMP_FILE)
            for SERVICE_STOP in SERVICE_RESTART; do
                f_log "stop $SERVICE_STOP"
                $SERVICE_STOP stop 1>/dev/null
            done
            sleep 5
            for SERVICE_START in SERVICE_RESTART; do
                f_log "start $SERVICE_START"
                $SERVICE_START start 1>/dev/null
                sleep 1
            done
            rm $TMP_FILE
            exit 1
        fi
    done
else
    f_log "CURL ERROR : $RETVAL"
    f_log $(cat $TMP_FILE)
    rm $TMP_FILE
    exit 1
fi
rm $TMP_FILE
exit 0
