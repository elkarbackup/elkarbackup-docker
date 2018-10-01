#! /bin/sh

EB_DIR=/app/elkarbackup

if [ -z "$SYMFONY_ENV" ];then
  export SYMFONY_ENV=prod
fi

# Run commands
if [ ! -z "$1" ]; then
  command="$@"
  echo "Command: $command"
  cd "${EB_DIR}" && $command
  exit $?
fi

# Check database connection
until mysqladmin ping -h "${SYMFONY__DATABASE__HOST}" --silent; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done

cd "${EB_DIR}"

# Create/update database
php app/console doctrine:database:create
php app/console doctrine:migrations:migrate --no-interaction
# Create admin user
php app/console elkarbackup:create_admin

# Set permissions
setfacl -R -m u:www-data:rwX app/cache app/sessions app/logs
setfacl -dR -m u:www-data:rwX app/cache app/sessions app/logs

if [ ! -z "$SYMFONY__EB__PUBLIC__KEY" ] && [ ! -f "$SYMFONY__EB__PUBLIC__KEY" ];then
  ssh-keygen -t rsa -N "" -C "Web requested key for elkarbackup." -f "${SYMFONY__EB__PUBLIC__KEY%.*}";
fi

# Clear cache and sessions, build assetics...
php app/console cache:clear
php app/console assetic:dump

rm -rf app/sessions/*
rm -rf app/cache/*

# Cron
if [ "${EB_CRON}" == "enabled" ]; then
  echo -e "\n\nEB_CRON is enabled. Running tick command every 10 seconds..."
  watch -t -n10 php app/console elkarbackup:tick --env=prod
fi