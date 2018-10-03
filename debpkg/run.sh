#!/usr/bin/env bash

docker run --rm --name ebname \
	   -v $(pwd):/export \
		 -e UID=$(id -u) \
		 -e GID=$(id -g) \
		 -e "GIT_REPO=https://github.com/elkarbackup/elkarbackup.git" \
		 -e "PHP_VERSION=5" \
		 -e "EB_VERSION=1.3.0" \
		 elkarbackup/deb:latest
