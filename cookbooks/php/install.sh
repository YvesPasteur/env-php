#!/bin/bash

d=`date`
echo "$d - Installation de PHP"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

PATH=$PATH:/usr/local/bin

if type -P php &>/dev/null; then
  echo "PHP est déjà installé"
else
  echo "Installe PHP"

  yum install -y -q libxml2-devel curl-devel libpng-devel libpng
  error_handler $? "Probleme lors de l'installation des packages de dependance"
  echo "Installation packages de dependance OK"

  yum install -y -q /vagrant/cookbooks/php/php-1_x86_64.rpm
  error_handler $? "Probleme lors de l'installation du RPM de PHP"
  echo "Installation de PHP OK"

  cp /vagrant/cookbooks/php/php.ini-development /usr/local/lib/php.ini
  error_handler $? "Erreur lors de la copie du php.ini"

  # decommente la ligne avec libphp5.so
  sed -i 's/#\(.*libphp5\.so\)/\1/' /etc/httpd/conf/httpd.conf
  error_handler $? "Erreur lors de l'activation du module PHP dans Apache"

fi

sudo apachectl restart

d=`date`
echo "$d - Fin d'installation de PHP"
