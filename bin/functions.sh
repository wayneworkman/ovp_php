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
    mkdir -p /data/qrCodes
    mkdir -p /data/jobs
    if [[ -e /data/scripts/processupload.sh ]]; then
        rm -f /data/scripts/processupload.sh
    fi
    cp $cwd/processupload.sh /data/scripts
    chown -R $webpermissions /data
    if [[ -z $(command -v semanage) ]]; then
        semanage fcontext -a -t httpd_sys_rw_content_t '/data'
        restorecon -v '/data'
        touch /etc/selinux/targeted/contexts/files/file_contexts.local
        ausearch -c 'httpd' --raw | audit2allow -M my-httpd
        semodule -i my-httpd.pp
    fi
    echo "Done"
}
checkFfmpeg() {
    dots "Searching for ffmpeg binary"
    ffmpeg=$(find /data/ffmpeg -type f -name ffmpeg)
    if [[ ! -e $ffmpeg ]]; then
        echo "Not found, exiting"
        exit
    else
        echo "Found"
    fi
}
setupConversion() {
    dots "Setting up processupload.service"
    if [[ -e /data/scripts/mysqlCredentials.sh ]]; then
        rm -f /data/scripts/mysqlCredentials.sh
    fi
    cp $cwd/mysqlCredentials.sh /data/scripts/mysqlCredentials.sh 
    if [[ -e /usr/lib/systemd/system/processupload.service ]]; then
        rm -f /usr/lib/systemd/system/processupload.service
    fi
    cp $cwd/processupload.service /usr/lib/systemd/system
    if [[ -e /data/scripts/processupload.sh ]]; then
        rm -f /data/scripts/processupload.sh
    fi
    cp $cwd/processupload.sh /data/scripts
    systemctl enable processupload.service
    systemctl restart processupload.service
    [[ $? -eq 0 ]] && echo "Succcess" || echo "Failed"
}
configureFirewalldWeb() {
    dots "Configure firewalld if present"
    if [[ -e $(command -v firewall-cmd) ]]; then
        for service in http https; do firewall-cmd --permanent --zone=public --add-service=$service; done > /dev/null 2>&1
        systemctl restart firewalld
        echo "Configured"
    else
        echo "Not needed"
    fi
}
configureFirewalldDb() {
    dots "Configure firewalld if present"
    if [[ -e $(command -v firewall-cmd) ]]; then
        for service in mysql; do firewall-cmd --permanent --zone=public --add-service=$service; done > /dev/null 2>&1
        systemctl restart firewalld
        echo "Configured"
    else
        echo "Not needed"
    fi
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
installCurl() {
    if [[ -z $(command -v curl) ]]; then
        dots "Installing curl"
        if [[ ! -z $(command -v dnf) ]]; then
            dnf -y install curl > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v yum) ]]; then
            yum -y install curl > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v apt-get) ]]; then
            apt-get -y install curl > /dev/null 2>&1
            result=$?
        else
            echo "Don't know how to install curl, please install it first."
        fi
        if [[ "$result" == "0" ]]; then
            echo "curl successfully installed."
        else
            echo "curl failed to install, exit code was \"$result\". Please install it first."
        fi
    fi
}
installQrencode() {
    if [[ -z $(command -v qrencode) ]]; then
        dots "Installing qrencode"
        if [[ ! -z $(command -v dnf) ]]; then
            dnf -y install qrencode > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v yum) ]]; then
            yum -y install qrencode > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v apt-get) ]]; then
            apt-get -y install qrencode > /dev/null 2>&1
            result=$?
        else
            echo "Don't know how to install qrencode, please install it first."
        fi
        if [[ "$result" == "0" ]]; then
            echo "qrencode successfully installed."
        else
            echo "qrencode failed to install, exit code was \"$result\". Please install it first."
        fi
    fi
}
installMysql() {
    if [[ -z $(command -v mysql) ]]; then
        dots "Installing mariadb"
        if [[ ! -z $(command -v dnf) ]]; then
            dnf -y install mariadb > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v yum) ]]; then
            yum -y install mariadb > /dev/null 2>&1
            result=$?
        elif [[ ! -z $(command -v apt-get) ]]; then
            apt-get -y install mariadb > /dev/null 2>&1
            result=$?
        else
            echo "Don't know how to install mariadb, please install it first."
        fi
        if [[ "$result" == "0" ]]; then
            echo "mariadb successfully installed."
        else
            echo "mariadb failed to install, exit code was \"$result\". Please install it first."
        fi
    fi
}
installDb() {
    local rhelPackages="mariadb-server"
    local rhel7extras=""
    local debianPackages="mysql-client mysql-common mysql-server"
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
installWeb() {
    local rhelPackages="php httpd php-mysqlnd setroubleshoot-server mod_ssl certbot-apache"
    local rhel7extras="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm http://rpms.remirepo.net/enterprise/remi-release-7.rpm yum-utils"
    local debianPackages="apache2 libapache2-mod-php5 php5 php5-common php5-cli php5-mysql php5-mcrypt qrencode mediainfo"
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
        #This stuff is for later version of PHP, CentOS 7 comes with php5 as standard. We need at least php7.
        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm > /dev/null 2>&1
        yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm > /dev/null 2>&1
        yum -y install yum-utils > /dev/null 2>&1
        yum-config-manager --enable remi-php71 > /dev/null 2>&1
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
getFfmpeg() {
    dots "Getting ffmpeg"
    #Get it. Could probably be done with curl - but curl doesn't come standard either. It's like choosing what t-shirt to put on. Meh.
    curl --silent https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz > /tmp/ffmpeg-release-64bit-static.tar.xz
    [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    dots "Extracting ffmpeg"
    #Make directories if not present.
    mkdir -p /data/ffmpeg
    mkdir -p /data/ffmpeg-old
    #Move old versions if present.
    mv /data/ffmpeg/* /data/ffmpeg-old > /dev/null 2>&1
    #Extract.
    tar -xf /tmp/ffmpeg-release-64bit-static.tar.xz -C /data/ffmpeg
    [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    rm -f /tmp/ffmpeg-release-64bit-static.tar.xz
    
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

    #Set mysql options.
    options="-sN"
    if [[ $mysqlHost != "" ]]; then
        options="$options -h$mysqlHost"
    fi
    if [[ $mysqlUser != "" ]]; then
        options="$options -u$mysqlUser"
    fi
    if [[ $mysqlPass != "" ]]; then
        options="$options -p$mysqlPass"
    fi
    options="$options -D $database -e"


    DBExists=$(mysql $options "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'ovp'")
    if [[ "$DBExists" != "ovp" ]]; then
        echo "Does not exist"
        dots "Creating ovp database"
        mysql $options < dbcreatecode.sql > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    else
        echo "Exists"
    fi
}
setupRemoteDb() {

    dots "Setting up remote DB"

    #Set mysql options.
    options="-sN"
    if [[ $mysqlHost != "" ]]; then
        options="$options -h$mysqlHost"
    fi
    if [[ $mysqlUser != "" ]]; then
        options="$options -u$mysqlUser"
    fi
    if [[ $mysqlPass != "" ]]; then
        options="$options -p$mysqlPass"
    fi
    options="$options -D $database "

    #echo "mysql $options < dbcreatecode.sql"

    mysql $options < dbcreatecode.sql > /dev/null 2>&1
    [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"


}
disableSelinux() {
    if [[ -e $(command -v setenforce) ]]; then
        dots "Setting SELinux to permissive"
        setenforce 0 > /dev/null 2>&1
        sed -i.bak 's/^.*\SELINUX=enforcing\b.*$/SELINUX=permissive/' /etc/selinux/config > /dev/null 2>&1
        [[ $? -eq 0 ]] && echo "Ok" || echo "Failed"
    fi
}
