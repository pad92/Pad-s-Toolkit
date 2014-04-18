#!/usr/bin/env sh

#{{{ Config
WWW_ROOT='/var/www/massvhosts'
SITE_NAME='$2'
ARCHIVE_DIR='/var/www/archives'
WWW_OWNER='ftpuser'
MYSQL_AUTH='/etc/mysql/debian.cnf'

DATE_NOW=$(date +'%Y%m%d-%H%M')
SITENAME=$(echo $SITE_NAME | sed 's/www\.//g' | sed 's/recette\.//g' | sed 's/\.croix-rouge.fr//g' | sed 's/\./-/g' | cut -c1-16 )
MYSQL_BDD=$SITENAME
MYSQL_USER=$SITENAME
FTP_USER=$SITENAME
#}}}

#{{{ Functions
# {{{ Create
#  {{{ Vhost
vhost_create() {
    echo '=> Apache'
    echo "-  Création des dossiers $WWW_ROOT/$SITE_NAME/{www,cgi-bin}"
    mkdir -p $WWW_ROOT/$SITE_NAME/www
    mkdir -p $WWW_ROOT/$SITE_NAME/cgi-bin
    chown -R  $WWW_OWNER $WWW_ROOT/$SITE_NAME/www
    chown -R  $WWW_OWNER $WWW_ROOT/$SITE_NAME/cgi-bin
}
#  }}}

#  {{{ MySQL
mysql_create() {
    echo '=> MySQL'
    MYSQL_PASSWD=$(pwgen 16 1)
    echo '-  Create database'
    mysql -e "create database $MYSQL_BDD"
    echo '-  Create database account'
    mysql -e "GRANT USAGE ON *.* TO '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWD';"
    mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_USER.* TO 'ftp'@'localhost' WITH GRANT OPTION;"
    echo "-  Utilisateur    : $MYSQL_USER"
    echo "-  Mot de passe   : $MYSQL_PASSWD"
    echo "-  Base de donnée : $MYSQL_BDD"
}
#  }}}

#  {{{ FTP
ftp_create() {
    echo "=> FTP"
    FTP_PASSWD=$(pwgen 16 1)
    echo "-  Créer compte pour $SITE_NAME"
    mysql ftp -e "INSERT INTO ftpuser (id, userid, passwd, uid, gid, homedir, shell, count, accessed, modified) VALUES ('', '$FTP_USER', ENCRYPT('$FTP_PASSWD'), 2001, 2001, '/var/www/massvhosts/$FTP_USER/www', '/sbin/nologin', 0, '', '');"
    echo "-  Utilisateur  : $FTP_USER"
    echo "-  Mot de passe : $FTP_PASSWD"
}
#  }}}
# }}}

# {{{ Delete
#  {{{ Vhost
vhost_delete() {
    echo '=> Apache'
    if [ -d "$WWW_ROOT/$SITE_NAME/" ]; then
        echo "-  Archive $SITE_NAME"
        tar cpzf $ARCHIVE_DIR/$SITE_NAME-$DATE_NOW.tar.gz $WWW_ROOT/$SITE_NAME/
        echo "-  Efface $WWW_ROOT/$SITE_NAME"
        rm -fr $WWW_ROOT/$SITE_NAME/
    else
        echo "- ERREUR : $WWW_ROOT/$SITE_NAME/ n'existe pas"
        exit 1
    fi
}
#  }}}

#  {{{ MySQL
mysql_delete() {
    echo '=> MySQL'
    echo "-  Archive BDD $MYSQL_BDD"
    mysqldump --single-transaction --routines $MYSQL_BDD | bzip2 > $ARCHIVE_DIR/$FTP_USER-$DATE_NOW-sql.bz2
    echo "-  Efface BDD $MYSQL_BDD"
    mysql -e "DROP DATABASE $MYSQL_BDD";
    echo "-  Archive du compte '$MYSQL_USER'@'localhost'"
    mysql -e "SHOW GRANT FOR '$MYSQL_USER'@'localhost';" > $ARCHIVE_DIR/$FTP_USER-$DATE_NOW-user-mysql.txt
    echo "-  Efface le compte '$MYSQL_USER'@'localhost'"
    mysql -e "DROP USER '$MYSQL_USER'@'localhost';"
}
#  }}}

#  {{{  FTP
ftp_delete() {
    echo "=> FTP"
    echo "-  Sauvegarde des informations dans $ARCHIVE_DIR/$FTP_USER-$DATE_NOW-ftp.txt"
    mysql ftp -e "SELECT * FROM ftpuser WHERE userid = $FTP_USER;" > $ARCHIVE_DIR/$FTP_USER-$DATE_NOW-user-ftp.txt
    echo "-  Suppression du compte pour $FTP_USER"
    mysql ftp -e "DELETE FROM ftpuser WHERE userid = $FTP_USER;"
}
#  }}}
# }}}

# {{{ Vhost Alias
vhost_alias() {
    echo '=> Apache'
    echo '-  create Vhost alias'
    if [ -d "$WWW_ROOT/$SITE_NAME/" ]; then
        ln -s $WWW_ROOT/$SITE_NAME $WWW_ROOT/$3 || echo "erreur lors de l'execution de ln -s $WWW_ROOT/$SITE_NAME $WWW_ROOT/$3 vérifier la source et déstination" && exit 1
        echo "-  $3 pointe sur $SITE_NAME"
    else
        echo "- ERREUR : $WWW_ROOT/$SITE_NAME/ n'existe pas"
    fi
}
# }}}

# {{{ Usage
usage() {
    echo "Usage : $(basename $0) [action]"
    echo "                       create [fqdn]"
    echo "                       delete [fqdn]"
    echo "                       alias  [fqdn] -> [fqdn]"
    exit 1
}
# }}}
#}}}

#{{{ Checks
# {{{ Arguments
## Au minimum deux parametre (action et domaine)
if [ "$#" -lt "2" ]; then
    usage
fi
# }}}

## check des binaires necessaires
# {{{ Binaires
BIN_DEPS='apache2ctl mysql pwgen mysqldump ln bzip2 tar'
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN \r\n apt-get install $BIN ? :)"
        exit 1
    fi
done
# }}}
#}}}

#{{{ Core
case $1 in
    create )
        vhost_create
        mysql_create
        ftp_create
        ;;
    delete )
        vhost_delete
        mysql_delete
        ftp_delete
        ;;
    alias )
        if [ "$@" -lt "3" ]; then
            usage
        else
            vhost_alias
        fi
        ;;
    * )
        usage ;;
esac
#}}}
