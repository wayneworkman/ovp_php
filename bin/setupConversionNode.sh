#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"




banner
checkForRoot
checkOS
#updateServer
installCurl
installMysql
installQrencode
getFfmpeg
checkFfmpeg
setupConversion



echo ' '
echo ' '
echo 'processupload.service should be running, will immediately begin processing jobs.'
echo ' '
