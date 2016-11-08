#!/bin/bash
#Change time 20160809 22:30 by Mr.Cui
zabbix_dir=/usr/local/zabbix/
zabbix_version=zabbix-3.0.4
read  -p "please input the zabbix_server IP address:" SERVER
echo ""
#read  -p "please input the zabbix_server port:(default:10050)" PORT
#echo ""
#yum -y  install  make gcc gcc-c++
tar zxf $zabbix_version.tar.gz
cd $zabbix_version
groupadd zabbix && useradd -r zabbix -g zabbix -s /sbin/nologin
./configure --prefix=$zabbix_dir --enable-agent
make && make install

sed -in s/"^Server=127.0.0.1"/"\nServer=$SERVER"/g $zabbix_dir/etc/zabbix_agentd.conf
#sed -i "s@^# Include=/usr/local/etc/zabbix_agentd.conf.d/@&\nInclude=/usr/local/zabbix/etc/zabbix_agentd.conf.d/@" $zabbix_dir/etc/zabbix_agentd.conf
sed -in s:"^# Include=/usr/local/etc/zabbix_agentd.conf.d/$":"\nInclude=/usr/local/zabbix/etc/zabbix_agentd.conf.d/":g $zabbix_dir/etc/zabbix_agentd.conf
sed -i "s@^# UnsafeUserParameters=0*@&\nUnsafeUserParameters=1@" $zabbix_dir/etc/zabbix_agentd.conf

cp ./misc/init.d/fedora/core/zabbix_agentd /etc/rc.d/init.d/zabbix_agentd
sed -in s:"BASEDIR=/usr/local":"BASEDIR=/usr/local/zabbix":g /etc/rc.d/init.d/zabbix_agentd

chkconfig zabbix_agentd on
service zabbix_agentd start
iptables -A INPUT -p tcp --dport 10050 -j ACCEPT
/etc/init.d/iptables save
echo -e "zabbix_agent installed successfully!"
