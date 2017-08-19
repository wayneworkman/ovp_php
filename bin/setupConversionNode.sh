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



banner
checkForRoot
checkOS
#updateServer
installCurl
installMysql
getFfmpeg
checkFfmpeg
setupConversion



echo ' '
echo ' '
echo 'processupload.service should be running, will immediately begin processing jobs.'
echo ' '
