#! /bin/bash

sleep 10

EB_PATH=${EB_PATH:=/usr/local/elkarbackup}

if [ ! -d "$EB_PATH" ];then
  bash -c "$(curl -s https://raw.githubusercontent.com/elkarbackup/elkarbackup/master/install/eb-installer.sh)" -s \
    -v "${EB_DEV:=dev}" \
    -h "${MYSQL_HOST:=db}" \
    -u "${MYSQL_EB_USER:=elkarbackup}" \
    -p "${MYSQL_EB_PASSWORD:=elkarbackup}" \
    -U "${MYSQL_ROOT_USER:=root}" \
    -P "${MYSQL_ROOT_PASSWORD:=changeme}" \
    -y \
    -d
  echo "Restarting apache..."
  service apache2 stop
  
  #Workaround to fix permissions issues (not ready for production)
  cd $EB_PATH
  sed -i '7s/^/umask(000);\n/' app/console
  sed -i '6s/^/umask(000);\n/' web/app.php
  sed -i '10s/^/umask(000);\n/' web/app_dev.php
  $EB_PATH/app/console cache:clear --env=prod
fi

/usr/sbin/apache2ctl -D FOREGROUND
