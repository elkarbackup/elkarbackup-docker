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

EB_PATH=${EB_PATH:=/usr/local/elkarbackup}
EB_INSTALLER=${EB_INSTALLER:=https://raw.githubusercontent.com/elkarbackup/elkarbackup/master/install/eb-installer.sh}

if [ ! -d "$EB_PATH/app" ];then
  bash -c "$(curl -s $EB_INSTALLER)" -s \
    -v "${EB_VERSION:=dev}" \
    -h "${MYSQL_HOST:=db}" \
    -u "${MYSQL_EB_USER:=elkarbackup}" \
    -p "${MYSQL_EB_PASSWORD:=elkarbackup}" \
    -U "${EB_DB_USERPASSWORD:=root}" \
    -P "${EB_DB_PASSWORD:=example}" \
    -y \
    -d
  echo "Restarting apache..."
  service apache2 stop
  
  #Workaround to fix permissions issues (don't do that outside a container)
  cd $EB_PATH
  sed -i '7s/^/umask(000);\n/' app/console
  sed -i '6s/^/umask(000);\n/' web/app.php
  sed -i '10s/^/umask(000);\n/' web/app_dev.php
  $EB_PATH/app/console cache:clear --env=prod

  # Create default backup storage dir
  # TODO: make this configurable with a app/console elkarbackup:<command>
  mkdir /var/spool/elkarbackup/backups
  setfacl -Rm u:elkarbackup:rwx /var/spool/elkarbackup
  setfacl -Rm u:www-data:rx /var/spool/elkarbackup/backups
fi

# Delete apache pid file (https://github.com/docker-library/php/issues/53)
if [ -f /run/apache2/apache2.pid ]; then
  rm -f /run/apache2/apache2.pid
fi
/usr/sbin/cron && /usr/sbin/apache2ctl -D FOREGROUND
