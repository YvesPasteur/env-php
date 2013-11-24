#!/bin/bash

d=`date`
echo "$d - Installation de la mini-appli"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

cd /var/www/html

if [ -f "composer.phar" ]; then
  echo "Composer déjà installé"
else
  echo "Récupère composer"
  curl -sS https://getcomposer.org/installer | /usr/local/bin/php
  error_handler $? "Erreur lors de la récupération de composer"
fi


PATH=$PATH:/usr/local/bin
cp /vagrant/cookbooks/appli/composer.json .
./composer.phar install
error_handler $? "Erreur lors de l'installation de Silex via composer"

echo "Initialisation DB"
mysql -D test < /vagrant/cookbooks/appli/db_init.sql
error_handler $? "Erreur lors de l'initialisation de la DB"

echo "Copie du fichier d'index"
cp /vagrant/cookbooks/appli/index.php /var/www/html/

echo "Copie du htaccess"
cp /vagrant/cookbooks/appli/.htaccess /var/www/html/

echo "Suppression de index.html"
rm /var/www/html/index.html

# conf apache
cp /vagrant/cookbooks/appli/main.conf /etc/httpd/sites-available/
ln -s /etc/httpd/sites-available/main.conf /etc/httpd/sites-enabled/

# firewall
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save


apachectl restart

d=`date`
echo "$d - Fin d'installation de la mini-appli"
