#!/usr/bin/env sh

BIN_DEPS='apg'

for BIN in $BIN_DEPS; do
   which $BIN 1>/dev/null 2>&1
   if [ $? -ne 0 ]; then
      echo "Error: Required file could not be found: $BIN"
      exit 1
   fi
done

genpw () {
   PW=$(apg -a 0 -M sncl -m 12 -x 12 -n 1 | egrep -iv [oli10])
   if [ "$PW" != "" ]; then
      echo $PW
      return 0;
   else
      return 1;
   fi
}

until genpw; do : ; done
