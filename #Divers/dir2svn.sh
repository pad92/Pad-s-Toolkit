#!/usr/bin/env bash

BIN_DEPS='svn'

if [ $# -eq 1 ]; then
   workingdir="$1"
else
   echo " Usage: $(basename $0) PATH" 
   echo ""
   echo "Automatically commits the changes of svn working copy located in PATH."
   echo "The new files are automatically added and the files that have been removed"
   echo "are removed."
   echo ""
   exit 1
fi

if [ -d $workingdir ] ; then
   echo $workingdir is not a accessible path.
   exit 1
fi

for BIN in $BIN_DEPS; do
    which -s $BIN
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

svn up --force
svnstatus=$(svn status $workingdir)
added=$(printf "%s" "$svnstatus" | sed -n 's/^[A?] *\(.*\)/\1/p')
removed=$(printf "%s" "$svnstatus" | sed -n 's/^! *\(.*\)/\1/p')

if [ "x$added" != "x" ]
then
   for file_added in $added; do
      if [ -f $file_added ]; then
         svn add "$file_added"
      fi
   done
fi

if [ "x$removed" != "x" ]
then
   for file_removed in $removed; do
      if [ ! -f $file_removed ]; then
         svn remove "$file_removed"
      fi
   done
fi

svn commit -m "autocommit"
