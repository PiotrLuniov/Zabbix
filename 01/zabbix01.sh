#!/bin/bash

ZABBIX_CONF="/etc/zabbix/zabbix_server.conf"

yum -y install vim mc net-tools
yum -y install mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
mysql -uroot<<EOM
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
quit;
EOM

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix


if [ $(grep -c "^DBHost=" $ZABBIX_CONF) -eq 0 ]; then
  echo "DBHost=localhost" >> $ZABBIX_CONF
fi

if [ $(grep -c "^DBName=" $ZABBIX_CONF) -eq 0 ]; then
  echo "DBName=zabbix" >> $ZABBIX_CONF
fi

if [ $(grep -c "^DBUser=" $ZABBIX_CONF) -eq 0 ]; then
  echo "DBUser=zabbix" >> $ZABBIX_CONF
fi

if [ $(grep -c "^DBPassword=" $ZABBIX_CONF) -eq 0 ]; then
  echo "DBPassword=zabbix" >> $ZABBIX_CONF
fi

systemctl start zabbix-server

sed -i '/\<IfModule mod_php5.c\>/a php_value date.timezone Europe\/Minsk' /etc/httpd/conf.d/zabbix.conf

systemctl start httpd
