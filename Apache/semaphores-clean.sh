#!/usr/bin/env bash

for semid in `ipcs -s | grep apache | cut -f2 -d" "`; do
    ipcrm -s $semid && echo -ne "."
done
echo -ne "\r\n"
