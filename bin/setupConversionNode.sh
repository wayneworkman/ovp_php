#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"

post_max_size="5G"
upload_max_filesize="5G"
memory_limit="5G"
max_execution_time="30000"
max_input_time="30000"




banner
checkForRoot
checkOS
updateServer
installCurl
checkFfmpeg
setupConversion



echo ' '
echo ' '
echo 'processupload.service should be running, will immediately begin processing jobs.'
echo ' '
