FROM ubuntu:16.04
MAINTAINER Xabi Ezpeleta <xezpeleta@gmail.com>

ENV EB_VERSION 1.2.7

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
    sudo \
    && rm -rf /var/lib/apt/lists/*

# TODO: Disable apache autostart service

# Elkarbackup repo
RUN wget -O - http://elkarbackup.org/apt/archive.gpg.key | apt-key add -
RUN wget https://github.com/elkarbackup/elkarbackup/releases/download/v$EB_VERSION/elkarbackup_$EB_VERSION-php7_all.deb

# Workaround for docker: change postinst
RUN dpkg --unpack elkarbackup_$EB_VERSION-php7_all.deb
COPY postinst /postinst

# Copy file to avoid file busy error
RUN cp /postinst /var/lib/dpkg/info/elkarbackup.postinst
RUN chmod u+x /var/lib/dpkg/info/elkarbackup.postinst

# Preconfigure Elkarbackup
RUN echo "elkarbackup elkarbackup/dbadminname text ${EB_DB_USER:=root}" | debconf-set-selections && \
 echo "elkarbackup elkarbackup/dbadminpassword password ${EB_DB_PASSWORD:=MYSQL_ROOT_PASSWORD}" | debconf-set-selections && \
 echo "elkarbackup elkarbackup/dbhost text ${EB_DB_HOST:=db}" | debconf-set-selections && \
 echo "elkarbackup elkarbackup/dbname text ${EB_DB_NAME:=elkarbackup}" | debconf-set-selections && \
 echo "elkarbackup elkarbackup/dbusername text ${EB_DB_USERNAME:=elkarbackup}" | debconf-set-selections && \
 echo "elkarbackup elkarbackup/dbuserpassword password ${EB_DB_USERPASSWORD:=elkarbackup}" | debconf-set-selections

RUN DEBIAN_FRONTEND="noninteractive" dpkg --configure elkarbackup && apt-get install -yf
# apt-get update && apt-get install -y -o Dpkg::Options::="--force-confold" elkarbackup


COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /var/spool/elkarbackup
VOLUME /etc/elkarbackup
VOLUME /var/lib/elkarbackup/.ssh

EXPOSE 80
EXPOSE 443
