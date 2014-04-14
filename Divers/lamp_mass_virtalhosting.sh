#!/usr/bin/env sh -x

### Config
WWW_ROOT='/var/www/massvhosts'
MYSQL_ROOT='/etc/mysql/debian.cnf'

### Functions
vhost_create() {
    echo '=> Apache'
    echo "-  Création des dossiers $MYSQL_ROOT/$2/{www,cgi-bin,logs}"
    mkdir -p $WWW_ROOT/$2/{www,cgi-bin,logs}
}

mysql_create() {
    echo '=> MySQL'
    MYSQL_PASSWD=$(pwgen 16 1)
    echo '-  Create database'
    echo '-  Create database account'
    echo "-  Utilisateur    : $MYSQL_USER"
    echo "-  Mot de passe   : $MYSQL_PASSWD"
    echo "-  Base de donnée : $MYSQL_BDD"
}

vhost_alias() {
    echo '=> Apache'
    echo '-  create Vhost alias'
    if [ -d "$WWW_ROOT/$2/" ]; then
        ln -s $WWW_ROOT/$2 $WWW_ROOT/$3 || echo "erreur lors de l'execution de ln -s $WWW_ROOT/$2 $WWW_ROOT/$3 vérifier la source et déstination" && exit 1
        echo "-  $3 pointe sur $2"
    else
        echo "- ERREUR : $WWW_ROOT/$2/ n'existe pas"
    fi
}

vhost_delete() {
    echo '=> Apache'
    if [ -d "$WWW_ROOT/$2/" ]; then
        echo "-  Archive $2"
        tar cpzf $WWW_ROOT/$2.tar.gz $WWW_ROOT/$2/
        echo "-  Efface $WWW_ROOT/$2"
        rm -fr $WWW_ROOT/$2/
    else
        echo "- ERREUR : $WWW_ROOT/$2/ n'existe pas"
        exit 1
    fi
}

mysql_delete() {
    echo '=> MySQL'
    echo "-  Archive BDD $2"
    echo "-  Efface BDD $2"
}

ftp_create() {
    echo "=> FTP"
    FTP_PASSWD=$(pwgen 16 1)
    echo "-  Créer compte pour $2"
    echo "-  Utilisateur  : $FTP_USER"
    echo "-  Mot de passe : $FTP_PASSWD"
}

ftp_delete() {
    echo "=> FTP"
    echo "-  Suppretion du compte pour $2"
}

usage() {
    echo "Usage : $(basename $0) [action]"
    echo "                       create [fqdn]"
    echo "                       delete [fqdn]"
    echo "                       alias  [fqdn] -> [fqdn]"
    exit 1
}

### Check
## Au minimum deux parametre (action et domaine)
if [ "$@" -lt "2" ]; then
    usage
fi

## check des binaires necessaires
BIN_DEPS='apache2ctl mysql pwgen'
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN \r\n apt-get install $BIN ? :)"
       # exit 1
    fi
done

### Core
case $1 in
    create )
        vhost_create
        mysql_create
        ;;
    delete )
        ;;
    alias )
        ;;
    * )
        usage ;;
esac
