# ElkarBackup

## Images

```
elkarbackup:dev   For testers and developers. Latest development version with Apache and PHP7
elkarbackup:deb   For testers and developers. It generates a DEB package using the latest Github code
```

## How to use this image

### Development environment

Using `docker-compose.yml`:

```yaml
version: '2'

services:

  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: changeme

  elkarbackup:
    image: elkarbackup/elkarbackup:dev
    ports:
      - 8080:80
    links:
      - db
    depends_on:
      - db
    environment:
      MYSQL_HOST: db
      MYSQL_ROOT_USER: root
      MYSQL_ROOT_PASSWORD: changeme
      MYSQL_EB_USER: elkarbackup
      MYSQL_EB_PASS: elkarbackup
```

### Generate DEB package

```
docker run --name ebdeb -v /root:/export -e "php=7" elkarbackup/elkarbackup:deb

-v <your-host-directory>:/export    DEB package will be stored here
-e "php=<number>"                   By default php=5 will be selected. For Ubuntu 16.04 select "php=7"
-e "tagname=<tag>"                  Will generate a custom DEB package using <tag> version
```
