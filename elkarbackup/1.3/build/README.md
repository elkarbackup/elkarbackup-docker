## Elkarbackup build

This is the docker image that we use to generate our Elkarbackup docker images.

After downloading and installing all the components, it generates a directory (/app/elkarbackup) with all the needed files. If you want to build your own ElkarBackup container, the best option is multistage:

```
#file: Dockerfile
#Download elkarbackup
COPY --from=elkarbackup/build:latest /app/elkarbackup /app/elkarbackup
```
.
Do you need a complete example? Here you have: https://github.com/elkarbackup/elkarbackup-docker/blob/master/elkarbackup/1.3/apache/Dockerfile

Note that some modifications are made to the code to adapt it to Docker environment.
