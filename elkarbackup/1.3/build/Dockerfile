FROM php:7.1-cli-alpine

RUN apk add --no-cache \
      git \
      curl \
      grep \
      mysql-client \
      acl \
      rsnapshot \
    && docker-php-ext-install \
      pdo_mysql \
      pcntl

# Prepare default directories
RUN mkdir -p -m 777 \
      /app \
      /app/uploads \
      /app/backups \
      /app/tmp \
      /app/.ssh

# Download and install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Download elkarbackup source code
ENV ELKARBACKUP_VERSION 1.3.5
ENV ELKARBACKUP_SHA256 9df3e1a4ad14b8908475d26769dd4eaba6a98a2cedd6a9d93bd72880ccceaec5
RUN set -ex; \
      curl -o elkarbackup.tar.gz -fSL "https://github.com/elkarbackup/elkarbackup/archive/v${ELKARBACKUP_VERSION}.tar.gz"; \
      echo "${ELKARBACKUP_SHA256}  elkarbackup.tar.gz" | sha256sum -c -; \
      tar -xzf elkarbackup.tar.gz -C /app/; \
      rm elkarbackup.tar.gz; \
      cd /app && mv elkarbackup-${ELKARBACKUP_VERSION} elkarbackup; \
      cd /app/elkarbackup; \
      mkdir -p app/cache app/sessions app/logs; \
      rm app/DoctrineMigrations/Version20130306101349.php;
      
## Download jquery
ENV JQUERY_VERSION 1.12.0
ENV JQUERY_SHA256 b8b6bc65c3d4795dc089ec29213d34a3074e9aa7f1ae31eb6c8e3a312c46e465
RUN set -ex; \
      cd /app/elkarbackup; \
      mkdir -p web/js/jquery && cd web/js/jquery; \
      curl -o jquery-"${JQUERY_VERSION}".min.js "http://code.jquery.com/jquery-${JQUERY_VERSION}.min.js"; \
      echo "${JQUERY_SHA256}  jquery-${JQUERY_VERSION}.min.js" | sha256sum -c -;

## Download Dojo
ENV DOJO_VERSION 1.8.14
ENV DOJO_SHA256 2023c8c8c8722b4c63976b7a269e20bda2fa09010706aef10b3821be81691727
RUN set -ex; \
      cd /app/elkarbackup; \
      mkdir -p web/js && cd web/js; \
      curl -o dojo.tar.gz "https://download.dojotoolkit.org/release-${DOJO_VERSION}/dojo-release-${DOJO_VERSION}.tar.gz"; \
      echo "${DOJO_SHA256}  dojo.tar.gz" | sha256sum -c -; \
      tar -xzf dojo.tar.gz && rm dojo.tar.gz;


## Custom composer.json (database not required)
COPY composer.json.docker /app/elkarbackup/composer.json

## Custom parameters.yml template with envars
COPY parameters.yml.docker /app/elkarbackup/app/config/parameters.yml.dist

## Custom config.yml (to log to stderr)
COPY config.yml.docker /app/elkarbackup/app/config/config.yml

## Custom app.php and app_dev.php (fixes env variables bug)
COPY app.php /app/elkarbackup/web/app.php
COPY app_dev.php /app/elkarbackup/web/app_dev.php

## Disable "Manage parameters" menu item
COPY src/Builder.php /app/elkarbackup/src/Binovo/ElkarBackupBundle/Menu/Builder.php

## Composer install
RUN set -ex; \
      cd /app/elkarbackup; \
      composer install --no-interaction

COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []


LABEL maintainer="Xabi Ezpeleta <xezpeleta@gmail.com>"
