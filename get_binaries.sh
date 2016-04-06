#!/bin/bash

if [ "$LOGNAME" != "root" ]
	then
	echo Need to run this as sudo
	exit 0
fi

echo Need sshpass to run this script...
sudo apt-get install sshpass

echo Getting binaries from malawitest. 
echo Please enter username for malawitest:
read user
echo Please enter password for malawitest:
read -s password

SCP_COMMAND="sshpass -p$password scp -o StrictHostKeyChecking=no $user@malawitest.pih-emr.org:/home/spochedley/pih-puppet-files/"

#echo "sshpass -p $password scp $user@malawitest.pih-emr.org:/home/spochedley/pih-puppet-malawi/"

cd /vagrant/

echo Ensure directories exist...

if [ ! -d "modules/openmrs-sync/files/" ]; then
 mkdir modules/openmrs-sync/files/
fi

if [ ! -d "modules/openmrs-sync/files/" ]; then
 mkdir modules/openmrs/files/
fi

if [ ! -d "modules/pih_java/files/" ]; then
 mkdir modules/pih_java/files/
fi

if [ ! -d "modules/pih_mysql/files/" ]; then
 mkdir modules/pih_mysql/files/
fi

if [ ! -d "modules/pih_tomcat/files/" ]; then
 mkdir modules/pih_tomcat/files/
fi

echo Getting latest yaml 
mv hieradata/common.yaml hieradata/common.yaml.orig
$SCP_COMMAND/common.yaml hieradata/

echo Getting keys for connecting to server
$SCP_COMMAND/id_rsa modules/openmrs-sync/files/

echo Getting modules
$SCP_COMMAND/modules.tar.gz modules/openmrs/files/modules.tar.gz

echo Getting database
$SCP_COMMAND/openmrs.tar.gz modules/openmrs/files/openmrs.tar.gz

echo Getting war
$SCP_COMMAND/openmrs.war modules/openmrs/files/openmrs.war

echo Getting java binaries
$SCP_COMMAND/binaries/pih_java/files/jdk-6u45-linux-x64.bin modules/pih_java/files/

echo Getting mysql binaries
$SCP_COMMAND/binaries/pih_mysql/files/mysql-5.6.15.tar.gz modules/pih_mysql/files/

echo Getting tomcat binaries
$SCP_COMMAND/binaries/pih_tomcat/files/apache-tomcat-6.0.36.tar.gz modules/pih_tomcat/files/

