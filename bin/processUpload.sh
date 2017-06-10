#!/bin/bash


#Variables.
domainName="perpetuum.io"
videoDir="/data/videos"
qrCodes="/data/qrCodes"
database="ovp"
mysqlhost="localhost"
mysqluser="processvideo"
mysqlpass="processvideopassword"
log="/data/logs/processVideo.log"
mysql=$(command -v mysql)
sha256sum=$(command -v sha256sum)
cut=$(command -v cut)
qrencode=$(command -v qrencode)

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


#Troubleshooting line
echo "file=\"$file\" vTitle=\"$vTitle\" uID=\"$uID\"" >> $log


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
filename=$(basename "$file")
extension="${filename##*.}"

if [[ "${#sum}" != "64" ]]; then
    #Sum is not 64 characters? Exit.
    echo "sum is not 64 characters, was ${#sum}" >> $log
    exit
else
    vID="${sum}.${extension}"
fi


#Store it into the DB.
$mysql $options "INSERT INTO Videos (vID,vTitle) VALUES (\"${vID}\",\"${vTitle}\")"
result=$?
if [[ "$result" != "0" ]]; then
    #Insert failed? Exit.
    echo "Insert into Videos failed, exit code $result : INSERT INTO Videos (vID,vTitle) VALUES (\"${vID}\",\"${vTitle}\")" >> $log
    exit
fi
$mysql $options "INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${vID}\",\"${uID}\")"
result=$?
if [[ "$result" != "0" ]]; then
    echo "Insert into UserVideoAssoc failed, exit code $result : INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${vID}\",\"${uID}\")" >> $log
    #Insert failed? Exit.
    exit
fi


#Move the file into place.
mv $file ${videoDir}/${vID}
#echo "mv $file ${videoDir}/${vID}" >> $log
if [[ "$?" != 0 ]]; then
    #Move failed? Exit.
    echo "Move failed for $file" >> $log
    exit
else
    #Generate a QR code for the link.
    if [[ ! -e ${qrCodes}/${sum}.png ]]; then
        $qrencode -o ${qrCodes}/${sum}.png "https://${domainName}/player.php?v=${vID}"
        if [[ "$?" != 0 ]]; then
            echo "QR generation failed for \"https://${domainName}/player.php?v=${vID}\"" >> $log
        
        fi
    fi
fi




