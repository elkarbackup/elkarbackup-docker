# ElkarBackup

## Images

```
elkarbackup:latest   Latest stable version, with Apache and PHP7
elkarbackup:dev      For testers and developers. Latest development version with Apache and PHP7
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
