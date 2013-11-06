#!/usr/bin/env sh

for IP in $@; do
    echo "# $IP :"
    echo -n | openssl s_client -connect $IP:443 | head -1
    echo
done
