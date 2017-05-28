#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"

banner
checkForRoot
checkOS
updateServer
checkOrInstallPackages "0"
setupDB
placeFiles
restartApache
restartMysql

echo ' '
echo ' '
echo 'Default user:pass is:'
echo 'admin'
echo 'changeme'
echo ' '
