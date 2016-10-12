#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Change time 20160214 22:40 by Mr.nando
#Use	create a simple shadowsocks server
#DEFINE Variables and function
ETCJSON=/etc/shadowsocks.json
IPTABLES=/etc/sysconfig/iptables

#There are four parameter need in the script, please input them by notice
#1.SERVERADDR	your server ip address.
#2.SERVERPORT	which port would be use for ssserver, such as "8989".
#3.PASSWORD		client need the password.
#4.METHOD		encryption method, just choose two of them, rc4-md5 & aes-256-cfb.

function Password()
{
	read -s -p "please input the password:" PASSWORD
	echo ""
	read -s -p "please input password again:" PASSWORD2
	PassCheck;
	return 0;
}

function PassCheck()
{
	if [ $PASSWORD != $PASSWORD2 ];then
		echo "error: two password is not match, please try again!"
		echo "(Ctrl+C to exit)"
		Password;
	fi
	return 0;
}

function ChangeETC()
{
	cat << EOF > $ETCJSON 
{
	"server":"$SERVERADDR",
	"server_port":$SERVERPORT,
	"local_address":"127.0.0.1",
	"local_port":1080,
	"password":"$PASSWORD",
	"timeout":600,
	"method":"$METHOD"
}
EOF
}

#A. install shadowsocks
yum install python-setuptools && easy_install pip
if [ $? -eq 0 ];then
	pip install shadowsocks
	if [ $? -eq 0 ];then
		echo "shadowsocks install successful."
	else
		echo "pip install shadowsocks error!"
	fi
else
	echo "install python-setuptools && easy_install pip error!" 
fi

#B. SERVERADDR & SERVERPORT
read -p "please input the ssserver ip address:" SERVERADDR
read -p "please input the ssserver port:" SERVERPORT

#PASSWORD(function)
Password;
	
#METHOD
echo -e "Encryption Method\n1.rc4-md5\n2.aes-256-cfb\nplease choose a encryption method,"
read -p "input the number:" KEY
case $KEY in
	1)
	METHOD=rc4-md5
	echo "encryption method is rc4-md5."
	;;
	2)
	METHOD=aes-256-cfb
	echo "encryption method is aes-256-cfb."
	;;
	*)
esac

#C. create config file(include iptables) and start ssserver
if [ -f $ETCJSON ];then
	echo "$ETCJSON exists, please ensure change Yes(y) or NO(n)"
	read i
	if [ "$i" == "y" -o "$i" == "Y" ];then
		mv -f $ETCJSON $ETCJSON.bak
		ChangeETC;
	else
		echo "$ETCJSON not change, break out."
        exit 0;
	fi
else
	ChangeETC;
fi

grep $SERVERPORT $IPTABLES
if [ $? != 0 ];then
	iptables -A INPUT -p tcp --dport $SERVERPORT -j ACCEPT
	service iptables save
	service iptables restart
fi

ssserver -c /etc/shadowsocks.json -d restart
echo -e "\nusage: ssserver -c /etc/shadowsocks.json -d start\nPS: if the config not exists, U can use...\nssserver -p $SERVERPORT -k $PASSWORD -m $METHOD -d start|restart\nShadowsocks is working, Bye."


