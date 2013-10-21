#!/bin/bash

d=`date`
echo "$d - Installation de MariaDB"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

###
# Version installation via depot de MariaDB
# plus long mais plus simple :)
###
#if [ -f "/etc/yum.repos.d/MariaDB.repo" ]; then
#  echo "MariaDB.repo already exists"
#else
#  cp /vagrant/cookbooks/mariadb/MariaDB.repo /etc/yum.repos.d/
#  error_handler $? "Config MariaDB repo"
#  echo "MariaDB.repo copied"
#fi

#if type -P mysql &>/dev/null; then
#  echo "MariaDB is already installed"
#else
#  echo "Install MariaDB"
#  yum install -y MariaDB-server MariaDB-client
#  error_handler $? "Probleme lors de l'installation de MariaDB"
#fi

if type -P mysql &>/dev/null; then
  echo "MariaDB est déjà installé"
else
  echo "Installe MariaDB"

  yum install -y  perl-DBI
  error_handler $? "Probleme lors de l'installation du package perl-DBI"

  # conflits lors de l'installation du package common de MariaDB
  yum remove -y mysql-libs
  error_handler $? "Probleme lors de la suppression de msqyl-libs"
  mariadb_cookdir='/vagrant/cookbooks/mariadb'
  yum install -y $mariadb_cookdir/MariaDB-5.5.33a-centos6-x86_64-compat.rpm $mariadb_cookdir/MariaDB-5.5.33a-centos6-x86_64-common.rpm $mariadb_cookdir/MariaDB-5.5.33a-centos6-x86_64-shared.rpm $mariadb_cookdir/MariaDB-5.5.33a-centos6-x86_64-client.rpm $mariadb_cookdir/MariaDB-5.5.33a-centos6-x86_64-server.rpm
  error_handler $? "Probleme lors de l'installation des packages Mariadb"


  /etc/init.d/mysql start
  error_handler $? "Probleme lors du demarrage de MariaDB"

  chkconfig --add mysql
  chkconfig --level 345 mysql on
fi


d=`date`
echo "$d - Fin d'installation de MariaDB"
