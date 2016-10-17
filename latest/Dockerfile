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
    wget \
    && rm -rf /var/lib/apt/lists/*

# Elkarbackup repo
RUN wget -O - http://elkarbackup.org/apt/archive.gpg.key | apt-key add -
RUN echo "deb http://elkarbackup.org/apt/ubuntu xenial main" > /etc/apt/sources.list.d/elkarbackup.list

COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
