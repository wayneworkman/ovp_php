#!/bin/bash

file=$1
if [[ -z $file ]]; then
    #No file passed? Exit.
    echo "No file passed"
    exit
fi
uID=$2
if [[ -z $uID ]]; then
    #No user passed? Exit.
    "No uID passed"
    exit
fi

if [[ ! -e $file ]]; then
    #File doesn't exist? Exit.
    echo "File doesn't exist"
    exit
fi

#Variables.
videoDir="/data/videos"
database="ovp"
mysqlhost=""
mysqluser="processvideo"
mysqlpass="processvideopassword"
mysql=$(command -v mysql)
sha256sum=$(command -v sha256sum)
cut=$(command -v cut)


if [[ -z $mysql ]]; then
    #mysql not present.
    echo "mysql not available"
    exit
fi

if [[ -z $sha256sum ]]; then
    echo "sha256sum not available"
    exit
fi

if [[ -z $cut ]]; then
    echo "cut not available"
    exit
fi


#Set mysql options.
options="-sN"
if [[ $snmysqlhost != "" ]]; then
        options="$options -h$mysqlhost"
fi
if [[ $snmysqluser != "" ]]; then
        options="$options -u$mysqluser"
fi
if [[ $snmysqlpass != "" ]]; then
        options="$options -p$mysqlpass"
fi
options="$options -D $database -e"


#hash the file.
sum=$( $sha256sum $file | $cut -d' ' -f1)


if [[ "${#sum}" != "64" ]]; then
    #Sum is not 64 characters? Exit.
    echo "sum is not 64 characters, was ${#sum}"
    exit
fi


#Store it into the DB.
$mysql $options "INSERT INTO `Videos` (`vID`) VALUES (\"${sum}\")"
if [[ "$?" != 0 ]]; then
    #Insert failed? Exit.
    echo "Insert into VIdeos failed"
    exit
fi
$mysql $options "INSERT INTO `UserVideoAssoc` (`vID`,`uID`) VALUES (\"${sum}\",\"${uID}\")"
if [[ "$?" != 0 ]]; then
    echo "Insert into UserVideoAssoc failed"
    #Insert failed? Exit.
    exit
fi


#Move the file into place.
mv $file $videoDir
if [[ "$?" != 0 ]]; then
    #Move failed? Exit.
    echo "Move failed"
    exit
fi




