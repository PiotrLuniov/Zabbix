#!/bin/bash
yum -y install vim mc net-tools
yum -y install nginx java tomcat tomcat-webapps tomcat-admin-webapps
sed -i 's-.*:80 .*--' /etc/nginx/nginx.conf
#Start service
systemctl enable tomcat
systemctl start tomcat
systemctl enable nginx
systemctl start nginx
systemctl daemon-reload

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm

yum -y install zabbix-agent

sed -i 's/^Server=127\.0\.0\.1/Server=172\.33\.33\.11/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# ListenPort=10050/ListenPort=10050/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=127\.0\.0\.1/ServerActive=172\.33\.33\.11/' /etc/zabbix/zabbix_agentd.conf

systemctl start zabbix-agent

#Sender
yum -y install zabbix-sender
