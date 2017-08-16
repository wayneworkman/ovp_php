#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"

#Check for passed mysql connection info after sourcing mysql credentials file.
if [[ ! -z $1 ]]; then
    mysqlUser="$1"
fi
if [[ ! -z $2 ]]; then
    mysqlPass="$2"
fi
if [[ ! -z $3 ]]; then
    mysqlHost="$3"
fi
if [[ ! -z $4 ]]; then
    database="$4"
fi

#Write the vars back to the files because any passed are likely not the ones stored.
echo "#!/bin/bash" > $cwd/mysqlCredentials.sh
echo "mysqlUser=\"processvideo\"" >> $cwd/mysqlCredentials.sh
echo "mysqlPass=\"processvideopassword\"" >> $cwd/mysqlCredentials.sh
echo "mysqlHost=\"localhost\"" >> $cwd/mysqlCredentials.sh
echo "database=\"ovp\"" >> $cwd/mysqlCredentials.sh



post_max_size="5G"
upload_max_filesize="5G"
memory_limit="5G"
max_execution_time="30000"
max_input_time="30000"




banner
checkForRoot
checkOS
#updateServer
installWeb "0"
placeFiles
configurePHP
configureApache
configureFirewalldWeb
disableSelinux

echo ' '
echo ' '
echo 'Default user:pass is:'
echo 'admin'
echo 'changeme'
echo ' '
