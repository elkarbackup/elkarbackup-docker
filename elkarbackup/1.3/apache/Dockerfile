FROM php:7.1-apache
RUN apt-get update && apt-get install -y \
      default-mysql-client \
      acl \
      rsnapshot \
      sudo \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install \
      pdo_mysql \
      pcntl

COPY --from=elkarbackup/build:1.3.3 /app /app

# Apache configuration
COPY elkarbackup.conf /etc/apache2/sites-available
RUN a2enmod rewrite \
  && a2dissite 000-default \
  && a2dissite default-ssl \
  && a2ensite elkarbackup

# Sudoers for script execution with environment variables
RUN echo "Cmnd_Alias ELKARBACKUP_SCRIPTS=/app/uploads/*" >> /etc/sudoers.d/elkarbackup
RUN echo "Defaults!ELKARBACKUP_SCRIPTS env_keep += \"ELKARBACKUP_LEVEL ELKARBACKUP_EVENT ELKARBACKUP_URL ELKARBACKUP_ID ELKARBACKUP_PATH ELKARBACKUP_STATUS ELKARBACKUP_CLIENT_NAME ELKARBACKUP_JOB_NAME ELKARBACKUP_OWNER_EMAIL ELKARBACKUP_RECIPIENT_LIST ELKARBACKUP_CLIENT_TOTAL_SIZE ELKARBACKUP_JOB_TOTAL_SIZE ELKARBACKUP_JOB_RUN_SIZE ELKARBACKUP_CLIENT_STARTTIME ELKARBACKUP_CLIENT_ENDTIME ELKARBACKUP_JOB_STARTTIME ELKARBACKUP_JOB_ENDTIME ELKARBACKUP_SSH_ARGS\"" >> /etc/sudoers.d/elkarbackup
RUN echo "elkarbackup ALL = NOPASSWD: ELKARBACKUP_SCRIPTS" >> /etc/sudoers.d/elkarbackup

# Add SSH default key location
RUN echo "    IdentityFile /app/.ssh/id_rsa" >> /etc/ssh/ssh_config

# Console commands log output
RUN ln -sf /proc/1/fd/1 /var/log/output.log

## Set timezone
RUN ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo "Europe/Paris" > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Paris"\n' > /usr/local/etc/php/conf.d/tzone.ini

COPY entrypoint.sh /
COPY envars.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []

VOLUME /app/backups
EXPOSE 80

LABEL maintainer="Xabi Ezpeleta <xezpeleta@gmail.com>"
