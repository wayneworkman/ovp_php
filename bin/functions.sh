#!/bin/bash
banner() {
    clear
    echo "             _______                   _____                    _____          ";
    echo "            /::\    \                 /\    \                  /\    \         ";
    echo "           /::::\    \               /::\____\                /::\    \        ";
    echo "          /::::::\    \             /:::/    /               /::::\    \       ";
    echo "         /::::::::\    \           /:::/    /               /::::::\    \      ";
    echo "        /:::/~~\:::\    \         /:::/    /               /:::/\:::\    \     ";
    echo "       /:::/    \:::\    \       /:::/____/               /:::/__\:::\    \    ";
    echo "      /:::/    / \:::\    \      |::|    |               /::::\   \:::\    \   ";
    echo "     /:::/____/   \:::\____\     |::|    |     _____    /::::::\   \:::\    \  ";
    echo "    |:::|    |     |:::|    |    |::|    |    /\    \  /:::/\:::\   \:::\____\ ";
    echo "    |:::|____|     |:::|    |    |::|    |   /::\____\/:::/  \:::\   \:::|    |";
    echo "     \:::\    \   /:::/    /     |::|    |  /:::/    /\::/    \:::\  /:::|____|";
    echo "      \:::\    \ /:::/    /      |::|    | /:::/    /  \/_____/\:::\/:::/    / ";
    echo "       \:::\    /:::/    /       |::|____|/:::/    /            \::::::/    /  ";
    echo "        \:::\__/:::/    /        |:::::::::::/    /              \::::/    /   ";
    echo "         \::::::::/    /         \::::::::::/____/                \::/____/    ";
    echo "          \::::::/    /           ~~~~~~~~~~                       ~~          ";
    echo "           \::::/    /                                                         ";
    echo "            \::/____/                                                          ";
    echo "             ~~                                                                ";
    echo "                                                                               ";
    echo "                                                                               ";
    echo "    Open Video Platform, making video hosting easy."
    echo " "
    echo "    Creator: Wayne Workman"
    echo " "
    echo " "
}
dots() {
    local pad=$(printf "%0.1s" "."{1..60})
    printf " * %s%*.*s" "$1" 0 $((60-${#1})) "$pad"
    return 0
}
placeFiles() {
    dots "Updating web files"
    rm -f /var/www/html/*
    cp ${cwd}/../web/* /var/www/html
    source "/etc/os-release"
    if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
        webpermissions="apache:apache"
    elif [[ "$ID" == "debian" ]]; then
        webpermissions="www-data:www-data"
    fi
    chown -R $webpermissions /var/www/html
    mkdir -p /data/videos
    mkdir -p /data/deleted
    mkdir -p /data/uploads
    mkdir -p /data/scripts
    mkdir -p /data/logs
    if [[ -e /data/scripts/processUpload.sh ]]; then
        rm -f /data/scripts/processUpload.sh
    fi
    cp $cwd/processUpload.sh /data/scripts
    chown -R $webpermissions /data
    echo "Done"
}
updateServer() {
    dots "Updating system, this could take a while"
    local useYum=$(command -v yum)
    local useDnf=$(command -v dnf)
    local useAptGet=$(command -v apt-get)
    if [[ -e "$useDnf" ]]; then
        dnf update -y > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Updated" || echo "Failed"
    elif [[ -e "$useYum" ]]; then
        yum update -y > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Updated" || echo "Failed"
    elif [[ -e "$useAptGet" ]]; then
        apt-get update > /dev/null 2>&1
        apt-get -y upgrade > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Updated" || echo "Failed"
    else
        echo "Failed"
        return 1
    fi
}
checkOS() {
    dots "Checking for compatible OS"
    if [[ -e "/etc/os-release" ]]; then
        source "/etc/os-release"
        if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" || "$ID" == "debian" ]]; then
            echo "$ID"
        else
            echo "$ID is incompatible"
            exit
        fi
    else
        echo "Could not determine OS"
        exit
    fi
}
configurePHP() {
    dots "Configuring PHP"
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
    echo "Done"
}
configureApache() {
    dots "Configuring Apache"
    if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
        systemctl restart httpd > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Success" || echo "Failed"
        systemctl enable httpd > /dev/null 2>&1
    elif [[ "$ID" == "debian" ]]; then
        systemctl restart apache2 > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Success" || echo "Failed"
        systemctl enable apache2 > /dev/null 2>&1
    fi
}
configureMysql() {
    dots "Configuring MySQL"
    if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
        systemctl restart mariadb > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Success" || echo "Failed"
        systemctl enable mariadb > /dev/null 2>&1
    elif [[ "$ID" == "debian" ]]; then
        systemctl restart mysql > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Success" || echo "Failed"
        systemctl enable mysql > /dev/null 2>&1
    fi
}
checkOrInstallPackages() {
    local rhelPackages="mariadb-server php httpd php-mysqlnd"
    local debianPackages="mysql-client mysql-common mysql-server apache2 libapache2-mod-php5 php5 php5-common php5-cli php5-mysql php5-mcrypt"
    local silent="$1"
    if [[ "$silent" -eq 0 ]]; then
        dots "Installing packages"
    fi
    local useYum=$(command -v yum)
    local useDnf=$(command -v dnf)
    local useAptGet=$(command -v apt-get)
    if [[ -e "$useDnf" ]]; then
        dnf -y install $rhelPackages > /dev/null 2>&1
        if [[ "$silent" -eq 0 ]]; then
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    elif [[ -e "$useYum" ]]; then
        yum -y install $rhelPackages > /dev/null 2>&1
        if [[ "$silent" -eq 0 ]]; then
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    elif [[ -e "$useAptGet" ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get -y install $debianPackages > /dev/null 2>&1
        if [[ "$silent" -eq 0 ]]; then
            [[ $? -eq 0 ]] && echo "Installed" || echo "Failed"
        fi
    else
        #Unable to determine repo manager.
        if [[ "$silent" -eq 0 ]]; then
            echo "Unable to determine repo manager."
        fi
        return 1
    fi
}
checkForRoot() {
    dots "Checking if I am root"
    currentUser=$(whoami)
    if [[ "$currentUser" == "root" ]]; then
        echo "I am $currentUser"
    else
        echo "I am $currentUser"
        exit
    fi

}
setupDB() {
    dots "Checking for ovp database"
    DBExists=$(mysql -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'ovp'")
    if [[ "$DBExists" != "ovp" ]]; then
        echo "Does not exist"
        dots "Creating ovp database"
        mysql < dbcreatecode.sql > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    else
        echo "Exists"
    fi
}
