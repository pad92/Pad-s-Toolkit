#!/usr/bin/env sh

TMP='/tmp/$$'

grep -rih security /etc/apt/sources.list* > $TMP
apt-get update
apt-get upgrade -oDir::Etc::Sourcelist=$TMP -s

rm $TMP

