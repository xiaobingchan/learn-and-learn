#!/bin/bash
# date         2019-03-04
# author       luyanjie
# company      NanWangZongBu
# version          1.0.1
#file:S0017-mysql-install.sh
#examples:sh :S0017-mysql-install.sh /root/boost_1_59_0.tar.gz /root/mysql-5.7.22.tar.gz /usr/local 123456

mkdir -p /data/soft/
cd  /data/soft/

wget https://downloads.mysql.com/archives/get/file/mysql-8.0.13-el7-x86_64.tar.gz
wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz


yum -y install gcc gcc-c++ ncurses ncurses-devel cmake

tar -zxvf /data/soft/boost_1_70_0.tar.gz -C /var/lib
tar -zxvf /data/soft/mysql-test-8.0.13-el7-x86_64.tar.gz -C /data/soft
cd /data/soft/mysql-8.0.13-el7-x86_64
cmake \
-DCMAKE_INSTALL_PREFIX=/data/soft/mysql \
-DMYSQL_DATADIR=/var/lib/mysql \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=/data/soft/boost_1_70_0.tar.gz \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=1
make
make install

userdel mysql
useradd -s /sbin/nologin mysql
cp /data/soft/mysql/support-files/mysql.server /etc/init.d/mysql
cat >/etc/my.cnf <<EOF
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
port=3306
socket=/tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
basedir=/data/soft/mysql
datadir=/var/lib/mysql
EOF

mkdir -p /var/lib/mysql
chmod -R 777 /var/lib/mysql
mkdir /var/log/mariadb
chown -R 777 /var/log/mariadb/
touch /var/log/mariadb/mariadb.log
mkdir /var/run/mariadb
chown -R 777 /var/run/mariadb/
touch /var/run/mariadb/mariadb.pid
mv /var/lib/mysql/ /var/lib/mysql_bak/

cat  >> /etc/profile << EOF
export PATH=\$PATH:/data/soft/mysql/bin:/data/soft/mysql/lib
EOF
source /etc/profile

pkill -9 mysql
cd /data/soft/mysql/bin/
./mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
/etc/init.d/mysql start

#输入用户密码和生成内置账户
mysql_password="123456"
echo "set password=password('${mysql_password}');"| mysql -S /tmp/mysql.sock
