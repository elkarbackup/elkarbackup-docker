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
ENV ELKARBACKUP_VERSION 1.3.0
ENV ELKARBACKUP_SHA1 ca53435768baf3bad347bdea4cbdbf3d4704eb31
RUN set -ex; \
      curl -o elkarbackup.tar.gz -fSL "https://github.com/elkarbackup/elkarbackup/archive/v${ELKARBACKUP_VERSION}.tar.gz"; \
      echo "${ELKARBACKUP_SHA1}  elkarbackup.tar.gz" | sha1sum -c -; \
      tar -xzf elkarbackup.tar.gz -C /app/; \
      rm elkarbackup.tar.gz; \
      cd /app && mv elkarbackup-${ELKARBACKUP_VERSION} elkarbackup; \
      cd /app/elkarbackup; \
      mkdir -p app/cache app/sessions app/logs; \
      rm app/DoctrineMigrations/Version20130306101349.php;
      
## Download jquery
ENV JQUERY_VERSION 1.12.0
ENV JQUERY_SHA1 66f47b885d587aa9a6c453ae3f2c9a382e5c7ec7
RUN set -ex; \
      cd /app/elkarbackup; \
      mkdir -p web/js/jquery && cd web/js/jquery; \
      curl -o jquery-"${JQUERY_VERSION}".min.js "http://code.jquery.com/jquery-${JQUERY_VERSION}.min.js"; \
      echo "${JQUERY_SHA1}  jquery-${JQUERY_VERSION}.min.js" | sha1sum -c -;

## Download Dojo
ENV DOJO_VERSION 1.8.14
ENV DOJO_SHA1 e23b9235d8f7a60c8fafbce3c731546d769f820a
RUN set -ex; \
      cd /app/elkarbackup; \
      mkdir -p web/js && cd web/js; \
      curl -o dojo.tar.gz "https://download.dojotoolkit.org/release-${DOJO_VERSION}/dojo-release-${DOJO_VERSION}.tar.gz"; \
      echo "${DOJO_SHA1}  dojo.tar.gz" | sha1sum -c -; \
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

## Composer install
RUN set -ex; \
      cd /app/elkarbackup; \
      composer install --no-interaction

COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []


LABEL maintainer="Xabi Ezpeleta <xezpeleta@gmail.com>"
