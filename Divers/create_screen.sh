#!/usr/bin/env sh

##
# Create screen with ~/.screenrc-* files

TRIG=$1

if [ -z "$1" ]; then
    echo "Utilisez en argument :"
    ls -1 ~/.screenrc* | cut -d'-' -f2 | sort
    exit 1
fi

if [ -f ~/.screenrc-$TRIG ]; then
    SCREEN_ACTIVE=$(screen -ls | tail -n +1 | sed  '$ d' | sed '$ d' | grep $TRIG)
    if [ -z "$SCREEN_ACTIVE" ]; then
        screen -c ~/.screenrc-$TRIG -S $TRIG
    else
        echo "Le screen existe deja !"
        echo $SCREEN_ACTIVE;
        exit 1
    fi
else
    echo "~/.screenrc-$TRIG n'existe pas"
    exit 1
fi
