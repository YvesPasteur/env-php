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

  # composer
  cd /var/www/xhgui

  if [ -f "composer.phar" ]; then
    echo "Composer déjà installé"
  else
    echo "Récupère composer"
    curl -sS https://getcomposer.org/installer | /usr/local/bin/php
    error_handler $? "Erreur lors de la récupération de composer"
  fi

  PATH=$PATH:/usr/local/bin

  ./composer.phar install --no-dev

  # conf apache
  cp /vagrant/cookbooks/xhprof/xhgui.conf /etc/httpd/sites-available/
  ln -s /etc/httpd/sites-available/xhgui.conf /etc/httpd/sites-enabled/

  # firewall
  iptables -I INPUT -p tcp --dport 81 -j ACCEPT
  service iptables save

  apachectl restart
fi


d=`date`
echo "$d - Fin Installation de Xhprof"
