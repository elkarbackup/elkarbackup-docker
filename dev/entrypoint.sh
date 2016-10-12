#! /bin/bash

sleep 10

EB_PATH=/usr/local/elkarbackup

if [ ! -d "$EB_PATH" ];then
  bash -c "$(curl -s https://gist.githubusercontent.com/xezpeleta/c5a5fe960b39cfab29e935dd381a4ab2/raw/eb-installer.sh)" -s \
    -v dev \
    -h "${MYSQL_HOST:=db}" \
    -u "${MYSQL_EB_USER:=elkarbackup}" \
    -p "${MYSQL_EB_PASS:=elkarbackup}" \
    -U "${MYSQL_ROOT_USER:=root}" \
    -P "${MYSQL_ROOT_PASS:=changeme}" \
    -y \
    -d
  echo "Restarting apache..."
  service apache2 stop
fi

/usr/sbin/apache2ctl -D FOREGROUND
