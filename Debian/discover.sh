#!/usr/bin/env sh

# You should be strict ! ( -e )
# Or want some debug ? ( -x )
set -e

# NOTES
# | mail -s "$HOSTNAME CHECK @ $(date +%Y.%m.%d-%H:%M)" user@domain.ltd

###
# {{{ Manifest
####################################################### 
# Discover host for :
# - migration
# - check new installation
# - verifiy old installation for conformity purpise
#
# Check domains
# - apache / apache2
# - nginx
# - lighttpd
# - varnish
# - php
# - memcached
# - mysql
# - percona
# - bind
# - mydns
# - crontabs
# - basics system hardening
# Internal functions
# - send output to file
# - send $this->file par mail
#
# TODO :
# - postgresql
# - CGI-BIN
#
# Yannick Foeillet
#######################################################
# }}} Manifest

### 
# {{{ CREATE WORKING DIR
###
[ ! -d "/tmp/$$/" ] && $(which mkdir) /tmp/$$ 
chmod -R 700 /tmp/$$
# }}}

###
# {{{ INIT
if [ ! -z "$1" ];then
	EMAIL=$1
else
	EMAIL="root@localhost"
fi

DPKG_CHECKS="apache nginx lighttpd varnish php memcache mysql percona bind mydns"
BIN_DEPS="df dpkg sendmail"
for BIN in $BIN_DEPS; do
	which $BIN 1>/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Error: Required file could not be found: $BIN"
		exit 1
	fi
done


SUBJECT=$(echo "AWH host check for $HOSTNAME @ $(date +%Y.%m.%d-%H:%M)" )
echo "SUBJECT:"$SUBJECT > /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
echo "---------- HOST ANALYSIS ----------" >> /tmp/$$/mail.tmp
echo "Date : " $( $(which date) +%Y.%m.%d-%H:%M:%S) >> /tmp/$$/mail.tmp
echo "Host : $HOSTNAME" >> /tmp/$$/mail.tmp
echo "Arch : " $( dpkg --print-architecture) >> /tmp/$$/mail.tmp
echo "Kernel : " $( $(which uname) -r) >> /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
echo "---------- FILESYSTEM SIZE ----------" >> /tmp/$$/mail.tmp
df '-h' >> /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
# }}} INIT

###
# {{{ DPKG
for DPKG_CHECK in $DPKG_CHECKS; do
	echo "---------- $DPKG_CHECK ----------" >> /tmp/$$/mail.tmp
	dpkg -l "*$DPKG_CHECK*" |grep ^.i | awk '{print $2" : "$3}' >> /tmp/$$/mail.tmp
	echo "" >> /tmp/$$/mail.tmp
done
# }}} DPKG

###
# {{{ CRONTABS
echo "---------- CRONTABS ----------" >> /tmp/$$/mail.tmp
echo "   ----- /var/spool/cron/crontabs/ ---" >> /tmp/$$/mail.tmp
spool_crons=$(ls -1 /var/spool/cron/crontabs/)
for scron in $( echo $spool_crons );do
	echo "      " /var/spool/cron/crontabs/$scron >> /tmp/$$/mail.tmp
done
echo "" >> /tmp/$$/mail.tmp
echo "   ----- /etc/cron.d/ ---" >> /tmp/$$/mail.tmp
etc_crons=$(ls -1 /etc/cron.d/)
for ecron in $( echo $etc_crons );do
	echo "      " /etc/cron.d/$ecron >> /tmp/$$/mail.tmp
done
echo "" >> /tmp/$$/mail.tmp
# }}} CRONTABS

###
# {{{ BASIC SYSTEM HARDENING
# PAM
echo "---------- PAM.D/SU CONTROL ----------" >> /tmp/$$/mail.tmp
pam_su=$(grep -c -E "auth[[:space:]]*required[[:space:]]*pam_wheel.so" /etc/pam.d/su |grep -v "^#")
if [ "$pam_su" -eq "0" ];then
	echo "*** pam.d/su not conform ! ***" >> /tmp/$$/mail.tmp	
fi
echo "" >> /tmp/$$/mail.tmp
# SSHD
echo "---------- SSHD_PERMIT_ROOT_LOGIN CONTROL ----------" >> /tmp/$$/mail.tmp
grep -E -i PermitRootLogin /etc/ssh/sshd_config |grep -v "^#" | awk '$2 ~ /yes/ {print "*** Security alert : "$0" ***"}' >> /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
# GROUP
echo "---------- NEXEN_IN_ROOT_GROUP CONTROL ----------" >> /tmp/$$/mail.tmp
grep -E "^root" /etc/group | awk -F":" '$0 !~ /nexen/ {print "*** Security alert : "$0" ***"}' >> /tmp/$$/mail.tmp
echo "" >> /tmp/$$/mail.tmp
# }}} BASIC SYSTEM HARDENING

# {{{ REPORT
cat /tmp/$$/mail.tmp | sendmail $EMAIL
# }}} REPORT

### 
# {{{ DELETE EXISTING WORKING DIR
###
[ -d "/tmp/$$/" ] && $(which rm) -rf /tmp/$$
# }}}

###
#{{{ vim vars
# vim: ts=4 sw=4 fdm=marker
# }}}
