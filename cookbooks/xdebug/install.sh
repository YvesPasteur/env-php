#!/bin/bash

d=`date`
echo "$d - Installation de Xdebug"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

PATH=$PATH:/usr/local/bin

installed=`php -m | grep -ic xdebug
`
if [ $installed -gt 0 ]; then
  echo "Xdebug est deja installe"
else
  echo "Installation de Xdebug"

  cp /vagrant/cookbooks/xdebug/xdebug.so /usr/local/lib/php/extensions/no-debug-zts-20121212/
  error_handler $? "Erreur lors de la copie du xdebug.so"

  # ajout de la declaration du xdebug.so dans le php.ini
  sed -i 's/;\(.*xdebug\.so\)/\1/' /usr/local/lib/php.ini

  # ajout de la configuration de xdebug

  echo "[xdebug]
  xdebug.remote_enable=on
  ; tous les clients pouvant acceder a la VM peuvent declencher le mode debug
  xdebug.remote_connect_back=on
  ; cle specifique a l'ide
  xdebug.idekey="toto-xdebug"
  xdebug.remote_log=/tmp/xdebug.log" >> /usr/local/lib/php.ini

  apachectl restart
fi


d=`date`
echo "$d - Fin Installation de Xdebug"
