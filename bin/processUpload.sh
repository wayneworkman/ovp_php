#!/bin/bash


#Variables.
videoDir="/data/videos"
database="ovp"
mysqlhost="localhost"
mysqluser="processvideo"
mysqlpass="processvideopassword"
log="/data/logs/processVideo.log"
mysql=$(command -v mysql)
sha256sum=$(command -v sha256sum)
cut=$(command -v cut)


file=$1
if [[ -z $file ]]; then
    #No file passed? Exit.
    echo "No file passed" >> $log
    exit
fi

vTitle=$2
if [[ -z $vTitle ]]; then
    #No vTitle passed? Exit.
    "No vTitle passed" >> $log
    exit
fi

uID=$3
if [[ -z $uID ]]; then
    #No user passed? Exit.
    "No uID passed" >> $log
    exit
fi


if [[ ! -e $file ]]; then
    #File doesn't exist? Exit.
    echo "File doesn't exist" >> $log
    exit
fi

if [[ -z $mysql ]]; then
    #mysql not present.
    echo "mysql not available" >> $log
    exit
fi

if [[ -z $sha256sum ]]; then
    echo "sha256sum not available" >> $log
    exit
fi

if [[ -z $cut ]]; then
    echo "cut not available" >> $log
    exit
fi


#Set mysql options.
options="-sN"
if [[ $mysqlhost != "" ]]; then
        options="$options -h$mysqlhost"
fi
if [[ $mysqluser != "" ]]; then
        options="$options -u$mysqluser"
fi
if [[ $mysqlpass != "" ]]; then
        options="$options -p$mysqlpass"
fi
options="$options -D $database -e"


#hash the file.
sum=$( $sha256sum $file | $cut -d' ' -f1)


if [[ "${#sum}" != "64" ]]; then
    #Sum is not 64 characters? Exit.
    echo "sum is not 64 characters, was ${#sum}" >> $log
    exit
fi


#Store it into the DB.
$mysql $options "INSERT INTO Videos (vID,vTitle) VALUES (\"${sum}\",\"${vTitle}\")"
if [[ "$?" != "0" ]]; then
    #Insert failed? Exit.
    echo "Insert into Videos failed, exit code $? : INSERT INTO Videos (vID,vTitle) VALUES (\"${sum}\",\"${vTitle}\")" >> $log
    exit
fi
$mysql $options "INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${sum}\",\"${uID}\")"
if [[ "$?" != "0" ]]; then
    echo "Insert into UserVideoAssoc failed, exit code $? : INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${sum}\",\"${uID}\")" >> $log
    #Insert failed? Exit.
    exit
fi


#Move the file into place.
mv $file $videoDir
if [[ "$?" != 0 ]]; then
    #Move failed? Exit.
    echo "Move failed" >> $log
    exit
fi




