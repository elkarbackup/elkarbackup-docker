# ElkarBackup

## Images

```
elkarbackup:latest   Latest stable version, with Apache and PHP7
elkarbackup:dev      For testers and developers. Latest development version with Apache and PHP7
elkarbackup:debpkg   For testers and developers. It generates a DEB package using the latest Github code
```

## How to use this image

```sh
$ docker run --name my-elkarbackup --link some-mysql:mysql -d elkarbackup/elkarbackup:latest
```

The following environment variables are also honored for configuring your ElkarBackup instance:

 - `-e MYSQL_HOST=...` (defaults to the IP and port of the linked `db` container)
 - `-e MYSQL_ROOT_USER=...` (defaults to "root")
 - `-e MYSQL_ROOT_PASSWORD=...` (needed!)
 - `-e MYSQL_EB_PASSWORD=...` (defaults to "elkarbackup")

### ... via `docker-compose`

You can use **Docker Compose** to easily run ElkarBackup in an isolated environment built with Docker containers:

**docker-compose.yml**
```yaml
version: '2'

services:

  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: changeme

  elkarbackup:
    image: elkarbackup/elkarbackup:latest
    ports:
      - 80:80
      - 443:443
    links:
      - db
    depends_on:
      - db
    environment:
      MYSQL_HOST: db
      MYSQL_ROOT_USER: root
      MYSQL_ROOT_PASSWORD: changeme
      MYSQL_EB_PASSWORD: elkarbackup
```

Run `docker-compose up`, wait for it to initialize completely, and visit https://localhost or https://host-ip


### elkarbacup:dev development environment

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
      - 80:80
      - 443:443
    links:
      - db
    depends_on:
      - db
    environment:
      MYSQL_HOST: db
      MYSQL_ROOT_USER: root
      MYSQL_ROOT_PASSWORD: changeme
      MYSQL_EB_USER: elkarbackup
      MYSQL_EB_PASSWORD: elkarbackup
```

### Build DEB package

A Docker image to quickly make an Elkarbackup (latest stable version) Debian package

To build, indicate the version (if not, will take latest stable version) and launch the docker container:

```
docker run --name ebdebpkg -v $(pwd):/export -e "php=7" elkarbackup/elkarbackup:debpkg

-v <your-host-directory>:/export    DEB package will be stored here
-e "php=<number>"                   By default php=5 will be selected. For Ubuntu 16.04 select "php=7"
-e "tagname=<tag>"                  Will generate a custom DEB package using <tag> version
```

Now you'll have the .deb package in your current directory
