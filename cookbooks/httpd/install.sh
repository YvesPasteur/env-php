#!/bin/bash

d=`date`
echo "$d - Installation de HTTPD"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

if type -P apachectl &>/dev/null; then
  echo "Apache est déjà installé";
else
  echo "Installe Apache"

  # mailcap : necessaire pour httpd
  # lynx : necessaire pour apachtectl status
  yum install -y mailcap lynx
  error_handler $? "Probleme d'installation de mailcap et lynx"
  echo "Installation dépendances OK"

  httpd_cookdir='/vagrant/cookbooks/httpd'
  yum install -y $httpd_cookdir/apr-1.4.8-1.x86_64.rpm $httpd_cookdir/apr-util-1.5.2-1.x86_64.rpm $httpd_cookdir/httpd-2.4.6-1.x86_64.rpm
  test $? "Probleme d'installation des RPMs apr et/ou httpd"
  echo "Installation de apr et httpd OK"

  cp $httpd_cookdir/httpd.conf /etc/httpd/conf/httpd.conf
  test $? "Problème lors de la copie de httpd.conf"

  # firewall
  iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  service iptables save

  # désactivation de SeLinux pour que le DocumentRoot puisse être un répertoire partagé
  # desactivation temporaire - effective sans reboot
  setenforce 0
  # desactivation permanente - prise en compte apres reboot
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

fi

/usr/sbin/apachectl start


d=`date`
echo "$d - Fin d'installation de HTTPD"
