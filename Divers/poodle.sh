#!/usr/bin/env sh
ret=$(echo Q | timeout 5 openssl s_client -connect "${1-`hostname`}:${2-443}" -ssl3 2> /dev/null)
if echo "${ret}" | grep -q 'Protocol.*SSLv3'; then
    if echo "${ret}" | grep -q 'Cipher.*0000'; then
        echo "${1-`hostname`}:${2-443} : SSL 3.0 disabled"
    else
        echo "${1-`hostname`}:${2-443} : SSL 3.0 enabled"
    fi
else
    echo "${1-`hostname`}:${2-443} : SSL disabled or other error"
fi
