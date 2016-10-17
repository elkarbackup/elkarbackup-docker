#! /bin/bash

#$ebhome is defined in Dockerfile
#$tagname it can be defined in Dockerfile or ENVAR, or it can be empty
#$php it can be defined in Dockerfile or ENVAR, or it can be empty

cd $ebhome

# Update code from Git
git pull

# Select version
if [[ -z "$tagname" ]];then
    echo "Using the current Git version"
else
    # TODO: add the possibility to specify
    #       "latest" as tagname (latest stable tag)
    git checkout tags/$tagname
fi

debiancontrol=$ebhome/debian/DEBIAN/control

if [[ -z "$php" ]];then
    php=5
else
    if [[ "$php" == 7 ]];then
        php7version="-php7"
        php7depends="Depends: acl, debconf, php, php-cli, rsnapshot, mysql-client, php-mysql, sudo, apache2, libapache2-mod-php"
        echo "Selected PHP7, changing debian/control..."

        # Change Control line
        currentversion=`sed -n -e '/Version/ s/.*\: *//p' $debiancontrol`
        sed -i "s/Version:.*/Version: $currentversion$php7version/g" $debiancontrol

        # Change Depends line
        sed -i "s/Depends:.*/$php7depends/g" $debiancontrol
    fi
fi

./makepackage.sh

debfile=`ls *deb`

cp $debiancontrol "$debexport/control.debug"
mv $debfile $debexport
