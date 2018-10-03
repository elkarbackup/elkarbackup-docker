#! /bin/bash
set -e

# Environment variables:
# - $GIT_REPO
#     Defaults to https://github.com/elkarbackup/elkarbackup.git
#			You can use this variable to specify your own Elkarbackup clone
#			repository URL
#			Add "-b <branch>" if you want to select a custom branch. Example:
#				REPO="https://github.com/xezpeleta/elkarbackup.git -b fix-issue-79"
# - $PHP_VERSION
#			Defaults to PHP_VERSION=5
#
# - $EB_VERSION
#                       Use custom version tag (i.e. EB_VERSION=1.3.0)
#

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

##
## Use custom version tag for your build
## Example: EB_VERSION=1.3.0
##
if [ ! -z "$EB_VERSION" ];then
	echo "Updating version number to: $EB_VERSION"
	echo "- Updating debiancontrol..."
	debiancontrol=$DATA_DIR/debian/DEBIAN/control
	currentversion=`sed -n -e '/Version/ s/.*\: *//p' $debiancontrol`
	sed -i "s/Version:.*/Version: $EB_VERSION/g" $debiancontrol

	echo "- Updating login screen..."
	loginscreen=$DATA_DIR/src/Binovo/ElkarBackupBundle/Resources/views/Default/login.html.twig
	sed -i "s/v$currentversion/v$EB_VERSION/g" $loginscreen
fi

##
## We need to use different control files for PHP5 and PHP7
##

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

## Set correct permissions
if [ ! -z "$UID" ];
then
	chown -R "$UID" "$EXPORT_DIR/build"
fi

if [ ! -z "$GID" ];
then
	chgrp -R "$GID" "$EXPORT_DIR/build"
fi
