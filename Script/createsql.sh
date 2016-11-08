#!/bin/bash
dbrootpwd=yourpwd
read -p "please input the new dbname:" DBname
read -p "please input the new dbuser:" DBuser
read -p "please input the new dbpass:" DBpass
mysql -uroot -p${dbrootpwd} -e "create database ${DBname};"
mysql -uroot -p${dbrootpwd} -e "grant all privileges on ${DBname}.* to ${DBuser}@'localhost' identified by \"${DBpass}\" with grant option;"
mysql -uroot -p${dbrootpwd} -e "flush privileges;"
echo "database \"$DBname\" create Successful , DBusername is \"$DBuser\", password is\"$DBpass\" "
