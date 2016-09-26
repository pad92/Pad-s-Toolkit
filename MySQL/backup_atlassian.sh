#!/bin/sh

# Backup jira & confluence
# Inspired from https://aseith.com/pages/viewpage.action?pageId=18874387

MYCNF='/etc/mysql/debian.cnf'
JIRA_HOME=''
CONFLUENCE_HOME='/var/atlassian/application-data/confluence/attachments'
BACKUPDIR='/var/backups/atlassian'

if [ ! -d ${BACKUPDIR} ]; then
    mkdir ${BACKUPDIR}
else
    rm -rf ${BACKUPDIR}/*
fi
# Push all commands into a subshell, so that everything is
# done between the db lock
(
    echo "FLUSH TABLES WITH READ LOCK;"
    for i in $(mysql --defaults-file=${MYCNF} --skip-column-names -B -e "SHOW databases;" | egrep -v "^information_schema$|^performance_schema$"); do
        mysqldump --defaults-file=${MYCNF} -Q -c -C --add-drop-table --events --quick ${i} | xz > $BACKUPDIR/${i}.sql.xz 2>/dev/null
    done
    tar cJf ${BACKUPDIR}/application-backup.$(date +%F).txz ${JIRA_HOME} ${CONFLUENCE_HOME} ${BACKUPDIR}/*.xz
    rm ${BACKUPDIR}/*.xz
    echo "UNLOCK TABLES;"
) | mysql --defaults-file=${MYCNF} 
exit 0

