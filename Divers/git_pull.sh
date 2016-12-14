#!/bin/sh

for DIR in $(find ~/Documents -type d -iname '.git' | sed 's/\.git//g'); do
    echo " --- $DIR --- "
    /usr/bin/git --git-dir="$DIR.git" --work-tree="$DIR" pull -q
done
