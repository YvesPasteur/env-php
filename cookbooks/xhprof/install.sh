#!/bin/bash

d=`date`
echo "$d - Installation de Xhprof"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

PATH=$PATH:/usr/local/bin

installed=`php -m | grep -ic xhprof
`
if [ $installed -gt 0 ]; then
  echo "Xhprof est deja installe"
else
  echo "Installation de Xhprof"

  cp /vagrant/cookbooks/xhprof/xhprof.so /usr/local/lib/php/extensions/no-debug-zts-20121212/
  error_handler $? "Erreur lors de la copie du xhprof.so"

  # ajout de la configuration de xhprof

  echo "[xhprof]
  extension = xhprof.so
  xhprof.output_dir=/tmp" >> /usr/local/lib/php.ini


  # xhgui
  cp -r /vagrant/cookbooks/xhprof/xhgui /var/www/ 

  chmod -R 0777 /var/www/xhgui/cache

  apachectl restart
fi


d=`date`
echo "$d - Fin Installation de Xhprof"
