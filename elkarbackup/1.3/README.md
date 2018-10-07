# elkarbackup-docker

## Getting Started

```sh
# Download this code
git clone https://github.com/elkarbackup/elkarbackup-docker.git
cd elkarbackup/1.3

# Start docker-compose
docker-compose up -d
```

## Configuration: environment variables

You can configure your Docker Elkarbackup installation using environment variables.

All the supported envars and default settings are listed below. You can overwrite them, preferentially using the `docker-compose.yml` environment section.

### Database configuration

| name                        | default value | description |
|-----------------------------|---------------|-------------|
| SYMFONY__DATABASE__DRIVER   | pdo_mysql     | driver      |
| SYMFONY__DATABASE__PATH     | null          | db path (sqlite) |
| SYMFONY__DATABASE__HOST     | db            | db host     |
| SYMFONY__DATABASE__PORT     | 3306          | db port     |
| SYMFONY__DATABASE__NAME     | elkarbackup   | db name     |
| SYMFONY__DATABASE__USER     | root          | db user     |
| SYMFONY__DATABASE__PASSWORD | root          | db password |


### Mailer configuration

| name                        | default value | description  |
|-----------------------------|---------------|--------------|
| SYMFONY__MAILER__TRANSPORT  | smtp          | transport    |
| SYMFONY__MAILER__HOST       | localhost     | host         |
| SYMFONY__MAILER__USER       | null          | user         |
| SYMFONY__MAILER__PASSWORD   | null          | password     |
| SYMFONY__MAILER__FROM       | null          | from address |


### Elkarbackup configuration

| name                        | default value     | description |
|-----------------------------|-------------------|-------------|
| SYMFONY__EB__SECRET  | fba546d6ab6abc4a01391d161772a14e093c7aa2 | framework secret |
| SYMFONY__EB__UPLOAD__DIR         | /app/uploads | scripts directory |
| SYMFONY__EB__BACKUP__DIR         | /app/backups | backups directory |
| SYMFONY__EB__TMP__DIR            | /app/tmp     | tmp directory |
| SYMFONY__EB__URL__PREFIX         | null         | url path prefix (i.e. /elkarbackup) |
| SYMFONY__EB__PUBLIC__KEY         | /app/.ssh/id_rsa.pub | ssh publick key path |
| SYMFONY__EB__TAHOE__ACTIVE       | false        | - |
| SYMFONY__EB__MAX__PARALLEL__JOBS | 1            | v1.3 or higher |
| SYMFONY__EB__POST__ON__PRE__FAIL | true         | v1.3 or higher |

## Known issues
- [ ] Apparently not all logs are properly redirected to stdout/stderr
- [x] Parameters cannot be configured via web UI
  - menu item has been deleted
- [x] SSH keypair generation from web UI does not work.
  - Keys are generated from the docker entrypoint if don't exist.
- [ ] Disk usage indicator does not work in Alpine Linux images
