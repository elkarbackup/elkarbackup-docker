#! /bin/bash

dbadminusername=${EB_DB_USER:=root}
dbadminpassword=${EB_DB_PASSWORD:=MYSQL_ROOT_PASSWORD}
dbhost=${EB_DB_HOST:=db}
dbname=${EB_DB_NAME:=elkarbackup}
dbusername=${EB_DB_USERNAME:=elkarbackup}
dbuserpassword=${EB_DB_USERPASSWORD:=elkarbackup}

# DB password empty?
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

# Check database configuration. Create DB if it does not exist.
if ! mysql -u"$dbusername" -p"$dbuserpassword" -h"$dbhost" "$dbname" </dev/null &>/dev/null
then
    echo "Attempting to create DB $dbname and user $dbusername in $dbhost"
    echo 'Create database'
    echo "CREATE DATABASE IF NOT EXISTS \`$dbname\` DEFAULT CHARACTER SET utf8;" | mysql -u"$dbadminusername" -p"$dbadminpassword" -h"$dbhost"
    echo 'Create user'
    if [ "$dbhost" = localhost ]
    then
        user="'$dbusername'@localhost"
    else
        user="'$dbusername'"
    fi
    echo "GRANT ALL ON \`$dbname\`.* TO $user IDENTIFIED BY '$dbuserpassword';" | mysql -u"$dbadminusername" -p"$dbadminpassword" -h"$dbhost" || true
else
    echo DB seems to be ready
fi

# Configure parameters
echo 'Configure parameters'
sed -i "s#database_host:.*#database_host: $dbhost#"                 /etc/elkarbackup/parameters.yml
sed -i "s#database_name:.*#database_name: $dbname#"                 /etc/elkarbackup/parameters.yml
sed -i "s#database_user:.*#database_user: $dbusername#"             /etc/elkarbackup/parameters.yml
sed -i "s#database_password:.*#database_password: $dbuserpassword#" /etc/elkarbackup/parameters.yml

# Migrate and delete cache content
echo Delete cache content
rm -fR /var/cache/elkarbackup/*
echo Update DB
php /usr/share/elkarbackup/app/console doctrine:migrations:migrate --no-interaction >/dev/null || true
echo Create root user
php /usr/share/elkarbackup/app/console elkarbackup:create_admin >/dev/null || true
echo Clean cache
php /usr/share/elkarbackup/app/console cache:clear >/dev/null || true
echo Dump assets
php /usr/share/elkarbackup/app/console assetic:dump >/dev/null || true
echo Invalidate sessions
rm -rf /var/lib/elkarbackup/sessions/*


# set rwx permissions for www-data and the backup user in the cache and log directories
# as described in http://symfony.com/doc/current/book/installation.html#configuration-and-setup
echo Changing file permissions
username="elkarbackup"
setfacl  -R -m u:www-data:rwx -m u:$username:rwx /var/cache/elkarbackup 2>/dev/null || ( echo "ACLs not supported. Remount with ACL and reconfigure with 'dpkg --configure --pending'" && false )
setfacl -dR -m u:www-data:rwx -m u:$username:rwx /var/cache/elkarbackup
setfacl  -R -m u:www-data:rwx -m u:$username:rwx /var/log/elkarbackup
setfacl -dR -m u:www-data:rwx -m u:$username:rwx /var/log/elkarbackup
chown -R $username.$username /var/cache/elkarbackup /var/log/elkarbackup /var/spool/elkarbackup
chown -R www-data.www-data /var/lib/elkarbackup/sessions /etc/elkarbackup/parameters.yml /var/spool/elkarbackup/uploads
uploadsdir="/var/spool/elkarbackup/uploads"
olduploadsdir=`cat /etc/elkarbackup/parameters.yml|grep upload_dir|sed 's/.*: *//'`
mkdir -p "$uploadsdir" || true
if [ ! "$olduploadsdir" == "$uploadsdir" ]; then
  mv "$olduploadsdir"/* "$uploadsdir" || true
fi
chown -R www-data.www-data "$uploadsdir"
sed -i "s#upload_dir:.*#upload_dir: $uploadsdir#" /etc/elkarbackup/parameters.yml
sed -i -e "s#elkarbackupuser#$username#g" -e "s#\s*Cmnd_Alias\s*ELKARBACKUP_SCRIPTS.*#Cmnd_Alias ELKARBACKUP_SCRIPTS=$uploadsdir/*#" /etc/sudoers.d/elkarbackup
chmod 0440 /etc/sudoers.d/elkarbackup


# Allow www-data and elkarbackup user to write to /dev/stderr
if [ ! -f /tmp/logpipe ]; then
  mkfifo -m 600 /tmp/logpipe
fi
chown www-data:www-data /tmp/logpipe
setfacl -m u:www-data:rwx -m u:elkarbackup:rwx /tmp/logpipe
cat <> /tmp/logpipe 1>&2 &

# Log to stdout
sed -i 's/%kernel.logs_dir%\/BnvLog.log/\/tmp\/logpipe/g' /etc/elkarbackup/config.yml
sed -i 's/${APACHE_LOG_DIR}\/elkarbackup-ssl.access.log/\/proc\/self\/fd\/1/g' /etc/apache2/sites-available/elkarbackup-ssl.conf /etc/apache2/sites-available/elkarbackup.conf
sed -i 's/${APACHE_LOG_DIR}\/elkarbackup.error.log/\/proc\/self\/fd\/2/g' /etc/apache2/sites-available/elkarbackup-ssl.conf /etc/apache2/sites-available/elkarbackup.conf

# Delete apache pid file (https://github.com/docker-library/php/issues/53)
if [ -f /run/apache2/apache2.pid ]; then
  rm -f /run/apache2/apache2.pid
fi

if [ "$DISABLE_CRON" == "true" ]; then
  /usr/sbin/apache2ctl -D FOREGROUND
else
  /usr/sbin/cron && /usr/sbin/apache2ctl -D FOREGROUND
fi
