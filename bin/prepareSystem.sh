#!/bin/bash
yum -y update
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php71
yum -y update
yum -y install php httpd php-mysqlnd mariadb curl qrencode setroubleshoot-server git vim



post_max_size="5G"
upload_max_filesize="5G"
memory_limit="5G"
max_execution_time="30000"
max_input_time="30000"


if [[ -e /etc/php5/apache2/php.ini ]]; then
    sed -i "s/post_max_size = .*/post_max_size = ${post_max_size}/" /etc/php5/apache2/php.ini
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${upload_max_filesize}/" /etc/php5/apache2/php.ini
    sed -i "s/memory_limit = .*/memory_limit = ${memory_limit}/" /etc/php5/apache2/php.ini
    sed -i "s/max_execution_time = .*/max_execution_time = ${max_execution_time}/" /etc/php5/apache2/php.ini
    sed -i "s/max_input_time = .*/max_input_time = ${max_input_time}/" /etc/php5/apache2/php.ini
fi
if [[ -e /etc/php.ini ]]; then
    sed -i "s/post_max_size = .*/post_max_size = ${post_max_size}/" /etc/php.ini
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${upload_max_filesize}/" /etc/php.ini
    sed -i "s/memory_limit = .*/memory_limit = ${memory_limit}/" /etc/php.ini
    sed -i "s/max_execution_time = .*/max_execution_time = ${max_execution_time}/" /etc/php.ini
    sed -i "s/max_input_time = .*/max_input_time = ${max_input_time}/" /etc/php.ini
fi


if [[ -e $(command -v setenforce) ]]; then
    setenforce 0 > /dev/null 2>&1
    sed -i.bak 's/^.*\SELINUX=enforcing\b.*$/SELINUX=permissive/' /etc/selinux/config > /dev/null 2>&1
fi



