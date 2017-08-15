#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"
source "$cwd/mysqlCredentials.sh"

#Check for passed mysql connection info after sourcing mysql credentials file.
if [[ ! -z $1 ]]; then
    mysqlUser="$1"
else
    echo "Missing user argument, exiting."
    exit
fi
if [[ ! -z $2 ]]; then
    mysqlPass="$2"
else
    echo "Missing pass argument, exiting."
    exit
fi
if [[ ! -z $3 ]]; then
    mysqlHost="$3"
else
    echo "Missing host argument, exiting."
    exit
fi
if [[ ! -z $4 ]]; then
    database="$4"
else
    echo "Missing database argument, exiting."
    exit
fi


banner
setupRemoteDb


echo ' '
echo ' '
echo 'Database should be setup now.'
echo ' '
