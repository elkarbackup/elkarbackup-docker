#! /bin/bash

if [ ! -n "${MYSQL_ROOT_PASSWORD}" ] && [ ! -n "${EB_DB_PASSWORD}" ] ;then
  echo >&2 'error: unknown database root password'
  echo >&2 '  You need to specify MYSQL_ROOT_PASSWORD or EB_DB_PASSWORD'
  exit 1
fi

# Check database connection
until mysqladmin ping -h "${EB_DB_HOST:=db}" --silent; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done

# Preconfigure Elkarbackup
echo "elkarbackup elkarbackup/dbadminname text ${EB_DB_USER:=root}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbadminpassword password ${EB_DB_PASSWORD:=MYSQL_ROOT_PASSWORD}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbhost text ${EB_DB_HOST:=db}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbuserpassword password ${EB_DB_USERPASSWORD:=elkarbackup}" | debconf-set-selections && \

apt-get update && apt-get install -y -o Dpkg::Options::="--force-confold" elkarbackup

/usr/sbin/cron && /usr/sbin/apache2ctl -D FOREGROUND
