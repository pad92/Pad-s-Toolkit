#!/usr/bin/env sh

apt-get install lsb-release

DEBIAN_VERSION="$(lsb_release -cs)"

MIRROR=$(egrep "^deb.*${DEBIAN_VERSION}" '/etc/apt/sources.list' \
    | egrep -v "updates|-src|cdrom" \
    | head -n 1 \
    | cut --delimiter=" " --fields=2)

DEBIAN_VERSION="squeeze"
echo "# Debian contrib repository.
deb http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} main
deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} main

deb http://security.debian.org/ ${DEBIAN_VERSION}/updates main
deb-src http://security.debian.org/ ${DEBIAN_VERSION}/updates main" \
    > "/etc/apt/sources.list.d/${DEBIAN_VERSION}.list"

echo "# DotDeb repository.
deb http://packages.dotdeb.org ${DEBIAN_VERSION} all
deb-src http://packages.dotdeb.org ${DEBIAN_VERSION} all" \
    > "/etc/apt/sources.list.d/dotdeb-org-${DEBIAN_VERSION}.list"

wget 'http://www.dotdeb.org/dotdeb.gpg' \
    --quiet --output-document=- \
    | apt-key add -

echo "Package: *
Pin: origin packages.dotdeb.org
Pin-Priority: 200" \
    > '/etc/apt/preferences.d/dotdeb-org'

apt-get update

PACKAGES="$(wget "http://packages.dotdeb.org/dists/${DEBIAN_VERSION}/php5/binary-$(dpkg --print-architecture)" \
    --quiet --output-document=- \
    | grep "href=" | grep -v "h1" | grep -v "\.\./" \
    | sed -e 's/^[^>]*>\([^_]*\)_.*$/\1/' | tr "\n" " ")"
PECL_PACKAGES="$(wget "http://packages.dotdeb.org/dists/${DEBIAN_VERSION}/php5-pecl/binary-$(dpkg --print-architecture)" \
    --quiet --output-document=- \
    | grep "href=" | grep -v "h1" | grep -v "\.\./" \
    | sed -e 's/^[^>]*>\([^_]*\)_.*$/\1/' | tr "\n" " ")"
ALL_PACKAGES="$(wget "http://packages.dotdeb.org/dists/${DEBIAN_VERSION}/php5/binary-all" \
    --quiet --output-document=- \
    | grep "href=" | grep -v "h1" | grep -v "\.\./" \
    | sed -e 's/^[^>]*>\([^_]*\)_.*$/\1/' | tr "\n" " ")"

echo "Package: ${PACKAGES} \\
    ${PECL_PACKAGES} \\
    ${ALL_PACKAGES}
Pin: origin packages.dotdeb.org
Pin-Priority: 600" \
    > '/etc/apt/preferences.d/dotdeb-org-php5'

mkdir --parents '/etc/php5/conf.d' '/var/lib/php5'
chmod 733 '/var/lib/php5'
chmod o+t '/var/lib/php5'
echo '; Store sessions to /var/lib/php5
session.save_path = "/var/lib/php5"
session.gc_probability = 0' \
    > '/etc/php5/conf.d/000-session-store-default.ini'

apt-get install $(dpkg --get-selections \
    | grep 'php5' \
    | cut --fields=1 \
    | sed -e 's|.*|&/squeeze|g')
