#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
black_dir=/home/sshblack.txt

/bin/cat /var/log/secure | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1;}' > $black_dir
DEFINE="10"
for i in `cat $black_dir`
do
    IP="`echo $i | awk -F = '{print $1}'`"
    NUM="`echo $i | awk -F = '{print $2}'`"
        if [ $NUM -gt $DEFINE ]; then
                grep $IP /etc/hosts.deny > /dev/null
                if [ $? != 0 ]; then
                        echo "sshd:$IP:deny" >> /etc/hosts.deny
                fi
        fi
done
