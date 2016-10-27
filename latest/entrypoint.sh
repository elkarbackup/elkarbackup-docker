#! /bin/bash

if [ -z "$MYSQL_ROOT_PASSWORD" ];then
  echo >&2 'error: unknown database root password'
  echo >&2 '  You need to specify MYSQL_ROOT_PASSWORD'
  exit 1
fi

# Check database connection
until mysqladmin ping -h "${MYSQL_HOST:=db}" --silent; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done

# Preconfigure Elkarbackup
echo "elkarbackup elkarbackup/dbadminname text ${MYSQL_ROOT_USER:=root}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbadminpassword password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbhost text ${MYSQL_HOST:=db}" | debconf-set-selections && \
echo "elkarbackup elkarbackup/dbuserpassword password ${MYSQL_EB_PASSWORD:=elkarbackup}" | debconf-set-selections && \

apt-get update && apt-get install -y elkarbackup

/usr/sbin/apache2ctl -D FOREGROUND
