#!/bin/bash
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
#!!!test
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix
#<<EOM
#password
#EOM

if [ $(grep -c "^DBHost=" "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
  echo "DBHost=localhost" >> /etc/zabbix/zabbix_server.conf
fi

if [ $(grep -c "^DBName=" "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
  echo "DBName=zabbix" >> /etc/zabbix/zabbix_server.conf
fi

if [ $(grep -c "^DBUser=" "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
  echo "DBUser=zabbix" >> /etc/zabbix/zabbix_server.conf
fi

if [ $(grep -c "^DBPassword=" "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
  echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf
fi

systemctl start zabbix-server

sed -i '/\<IfModule mod_php5.c\>/a php_value date.timezone Europe\/Minsk' /etc/httpd/conf.d/zabbix.conf

systemctl start httpd

#Install agent
#yum install zabbix-agent

#sed -i 's/^Server=127\.0\.0\.1/Server=172\.33\.33\.22/' /etc/zabbix/zabbix_agentd.conf
#sed -i 's/# ListenPort=10050/ListenPort=10050/' /etc/zabbix/zabbix_agentd.conf
#sed -i 's/^ServerActive=127\.0\.0\.1/ServerActive=172\.33\.33\.22/' /etc/zabbix/zabbix_agentd.conf

#systemctl start zabbix-agent
