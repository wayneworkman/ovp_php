#!/bin/bash

yum -y update
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php71
yum -y update
yum -y install php httpd php-mysqlnd mariadb curl qrencode git vim python2-pip
pip install --upgrade pip
pip install awscli --upgrade
mkdir -p /root/.aws
echo '[default]' > /root/.aws/config
echo 'region = us-east-2' >> /root/.aws/config
chmod 600 /root/.aws/config
pip install pystache
pip install argparse

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

curl --silent https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz > /opt/aws-cfn-bootstrap-latest.tar.gz
tar -xzf /opt/aws-cfn-bootstrap-latest.tar.gz -C /opt
rm -f /opt/aws-cfn-bootstrap-latest.tar.gz
rm -rf /opt/aws
mv /opt/aws-cfn-bootstrap* /opt/aws
cd /opt/aws
python setup.py build
python setup.py install
cd bin
chmod +x *

