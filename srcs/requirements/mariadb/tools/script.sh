#!/bin/bash

# initialize the MySQL data directory and create the system tables if they don't exist yet
if [ ! -d "/var/lib/mysql/mysql" ]; then

    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

echo $db_database
# start the service, run the mysql_secure_installation equivalent and set up database and privileged user

mysqld_safe --datadir=/var/lib/mysql & 

sleep 5

mysql --user=root << _EOF_
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$db_root_password';
FLUSH PRIVILEGES;
_EOF_

chown -R mysql:mysql /var/lib/mysql

mysql --user=root --password=$db_root_password << _EOF_
CREATE DATABASE IF NOT EXISTS $db_database;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$db_root_password';
GRANT ALL PRIVILEGES ON $db_database.* TO '$db_user'@'%' IDENTIFIED BY '$db_password' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_

# Needed to stop service in order to run CMD mysqld in Dockerfile
mysqladmin -uroot -p$db_root_password shutdown

exec "$@"