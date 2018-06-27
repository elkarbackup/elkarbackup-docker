#! /bin/bash

# Environment variables:
# - $GIT_REPO
#     Defaults to https://github.com/elkarbackup/elkarbackup.git
#			You can use this variable to specify your own Elkarbackup clone
#			repository URL
#			Add "-b <branch>" if you want to select a custom branch. Example:
#				REPO="https://github.com/xezpeleta/elkarbackup.git -b fix-issue-79"
# - $PHP_VERSION
#			Defaults to PHP_VERSION=5

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

if [[ -z "$PHP_VERSION" ]];then
    php=5
else
	if [[ "$PHP_VERSION" == 7 ]];then
		debiancontrol=$DATA_DIR/debian/DEBIAN/control
		php7version="-php7"
		php7depends="Depends: acl, debconf, php, php-cli, php-xml, rsnapshot, mysql-client, php-mysql, sudo, apache2, libapache2-mod-php"
		echo "Selected PHP7, changing debian/control..."

		# Change Control line
		currentversion=`sed -n -e '/Version/ s/.*\: *//p' $debiancontrol`
		sed -i "s/Version:.*/Version: $currentversion$php7version/g" $debiancontrol

		# Change Depends line
		sed -i "s/Depends:.*/$php7depends/g" $debiancontrol
	fi
fi

./makepackage.sh

DEB_FILE=`ls *deb`

mkdir -p "$EXPORT_DIR/build"
mv "$DEB_FILE" "$EXPORT_DIR/build/"
