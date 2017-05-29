#!/bin/bash

file=$1
if [[ -z $file ]]; then
    #No file passed? Exit.
    exit
fi
uID=$2
if [[ -z $uID ]]; then
    #No user passed? Exit.
    exit
fi

if [[ ! -e $file ]]; then
    #File doesn't exist? Exit.
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


if [[ "${#sum}" != "256" ]]; then
    #Sum is not 256 characters? Exit.
    exit
fi


#Store it into the DB.
$mysql $options "INSERT INTO `Videos` (`vID`) VALUES (\"${sum}\")"
if [[ "$?" != 0 ]]; then
    #Insert failed? Exit.
    exit
fi
$mysql $options "INSERT INTO `UserVideoAssoc` (`vID`,`uID`) VALUES (\"${sum}\",\"${uID}\")"
if [[ "$?" != 0 ]]; then
    #Insert failed? Exit.
    exit
fi


#Move the file into place.
mv $file $videoDir
if [[ "$?" != 0 ]]; then
    #Move failed? Exit.
    exit
fi




