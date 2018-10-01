FROM php:7.1-apache
RUN apt-get update && apt-get install -y \
      mysql-client \
      acl \
      rsnapshot \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install \
      pdo_mysql \
      pcntl

COPY --from=elkarbackup/elkarbackup:1.3.0-build /app /app

# Apache configuration
COPY elkarbackup.conf /etc/apache2/sites-available
RUN a2enmod rewrite \
  && a2dissite 000-default \
  && a2dissite default-ssl \
  && a2ensite elkarbackup

# Console commands log output
RUN ln -sf /proc/1/fd/1 /var/log/output.log

COPY entrypoint.sh /
COPY envars.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []

VOLUME /app/backups
EXPOSE 80

LABEL maintainer="Xabi Ezpeleta <xezpeleta@gmail.com>"
