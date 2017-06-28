#! /bin/bash

sleep 10

EB_PATH=/usr/local/elkarbackup

if [ ! -d "$EB_PATH" ];then
  bash -c "$(curl -s https://raw.githubusercontent.com/elkarbackup/elkarbackup/master/install/eb-installer.sh)" -s \
    -v dev \
    -h "${MYSQL_HOST:=db}" \
    -u "${MYSQL_EB_USER:=elkarbackup}" \
    -p "${MYSQL_EB_PASSWORD:=elkarbackup}" \
    -U "${MYSQL_ROOT_USER:=root}" \
    -P "${MYSQL_ROOT_PASSWORD:=changeme}" \
    -y \
    -d
  echo "Restarting apache..."
  service apache2 stop
fi

/usr/sbin/apache2ctl -D FOREGROUND
