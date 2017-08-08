#!/bin/bash


#Variables.
domainName="perpetuum.io"
videoDir="/data/videos"
tmpDir="/data/tmp"
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
rm=$(command -v rm)
ffmpeg=$(find /data/ffmpeg -type f -name ffmpeg)
threads="16" #Number of threads to use in video conversion. This is per-process.


#Make all the directories if they aren't there.
mkdir -p $videoDir
mkdir -p $tmpDir
mkdir -p $qrCodes



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


#Get file name and extension.
filename=$(basename "$file")
extension="${filename##*.}"


#Check if it's an mp4 extension or not. Could use mediainfo here.
if [[ "$extension" != "mp4" && "$extension" != "MP4" ]]; then
    #It's not mp4, convert it. Try to preserve encoding instead of re-encoding if possible.

    if [[ "$extension" == "mkv" || "$extension" == "MKV" ]]; then
        # mkv conversion command here.
        $ffmpeg -threads $threads -i "$file" -vcodec copy -acodec copy "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            file="${tmpDir}/${filename}.mp4"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -threads $threads -i \"$file\" -vcodec copy -acodec copy \"${tmpDir}/${filename}.mp4\"" >> $log
        fi

    elif [[ "$extension" == "avi" || "$extension" == "AVI" ]]; then
        # avi conversion command here.
        $ffmpeg -threads $threads -i "$file" -c:v libx264 -preset slow -crf 20 -c:a libvo_aacenc -b:a 128k "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            file="${tmpDir}/${filename}.mp4"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -threads $threads -i \"$file\" -c:v libx264 -preset slow -crf 20 -c:a libvo_aacenc -b:a 128k \"${tmpDir}/${filename}.mp4\"" >> $log
        fi

    else
        # Best shot here.
        $ffmpeg -threads $threads -i "$file" "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            file="${tmpDir}/${filename}.mp4"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -threads $threads -i \"$file\" \"${tmpDir}/${filename}.mp4\"" >> $log
        fi
    fi

fi



#hash the file.
sum=$( $sha256sum $file | $cut -d' ' -f1)

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




