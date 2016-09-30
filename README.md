# ElkarBackup

## Images

```
elkarbackup:deb   For testers and developers. It generates a DEB package using the latest Github code
```

## How to use this image

```
docker run --name ebdeb -v /root:/export -e "php=7" elkarbackup/elkarbackup:deb

-v <your-host-directory>:/export    DEB package will be stored here
-e "php=<number>"                   By default php=5 will be selected. For Ubuntu 16.04 select "php=7"
-e "tagname=<tag>"                  Will generate a custom DEB package using <tag> version
```
