#!/usr/bin/env sh

# === CONFIG ===
APACHE_USER='apache'

# === CHECK ===
BIN_DEPS='ipcs ipcrm'
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

# === CORE ===
for SEM_ID in $(ipcs -s | grep $APACHE_USER | cut -f2 -d" "); do
    ipcrm -s $SEM_ID && echo -n "$SEM_ID "
done
echo -n "\r\n"
