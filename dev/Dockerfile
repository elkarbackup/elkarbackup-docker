FROM ubuntu:16.04
MAINTAINER Xabi Ezpeleta <xezpeleta@gmail.com>

# Install required dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    mysql-client \
    rsnapshot \
    zip \
    php-mysql \
    php-xml \
    libapache2-mod-php \
    curl \
    acl \
    bzip2 \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
