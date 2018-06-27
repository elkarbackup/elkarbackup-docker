#!/usr/bin/env bash

docker run --rm --name ebname \
	   -v $(pwd):/export \
		 -e UID=$(id -u) \
		 -e GID=$(id -g) \
		 -e "GIT_REPO=https://github.com/xezpeleta/elkarbackup.git -b fix-issue-580" \
		 -e "PHP_VERSION=7" \
		 elkarbackup/deb:latest
