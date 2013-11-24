#!/bin/bash

d=`date`
echo "$d - Installation de MongoDB"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

# source des RPMs
# http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/RPMS/

mongodb_cookdir='/vagrant/cookbooks/mongodb'
yum install -y $mongodb_cookdir/mongo-10gen-2.4.8-mongodb_1.x86_64.rpm $mongodb_cookdir/mongo-10gen-server-2.4.8-mongodb_1.x86_64.rpm
error_handler $? "Erreur lors de l'installation de mongodb"

PATH=$PATH:/usr/local/bin

installed=`php -m | grep -ic mongo
`
if [ $installed -gt 0 ]; then
  echo "Driver Mongo est deja installe"
else
  echo "Installation du driver Mongo"

  cp /vagrant/cookbooks/mongodb/mongo.so /usr/local/lib/php/extensions/no-debug-zts-20121212/
  error_handler $? "Erreur lors de la copie du mongo.so"

  # ajout de la configuration de xhprof

  echo "[mongo]
  extension = mongo.so" >> /usr/local/lib/php.ini

  mkdir -p /var/log/mongod/
  mkdir -p /data/db
fi

apachectl restart
mongod --smallfiles --logpath /var/log/mongod/mongod.log &

d=`date`
echo "$d - Fin Installation de MongoDB"
