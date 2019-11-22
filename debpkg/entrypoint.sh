#! /bin/bash
set -e

# Environment variables:
# - $GIT_REPO
#     Defaults to https://github.com/elkarbackup/elkarbackup.git
#			You can use this variable to specify your own Elkarbackup clone
#			repository URL
#			Add "-b <branch>" if you want to select a custom branch. Example:
#				REPO="https://github.com/xezpeleta/elkarbackup.git -b fix-issue-79"

DATA_DIR="/data/elkarbackup"
EXPORT_DIR="/export"

mkdir -p "$DATA_DIR" && cd "$DATA_DIR/.."

# Select version
if [ -z "$GIT_REPO" ];then
	GIT_REPO="https://github.com/elkarbackup/elkarbackup.git"
	echo "Version not specified. Using current Elkarbackup git repo: $GIT_REPO"
else
	echo "Selected git repo: $GIT_REPO"
fi

echo "Git clone..."
git clone $GIT_REPO

cd $DATA_DIR
./bootstrap.sh
./makepackage.sh

DEB_FILE=`ls *deb`

mkdir -p "$EXPORT_DIR/build"
mv "$DEB_FILE" "$EXPORT_DIR/build/"

## Set correct permissions
if [ ! -z "$UID" ];
then
	chown -R "$UID" "$EXPORT_DIR/build"
fi

if [ ! -z "$GID" ];
then
	chgrp -R "$GID" "$EXPORT_DIR/build"
fi
