#!/bin/bash


#Variables.
domainName="perpetuum.io"
videoDir="/data/videos"
tmpDir="/data/tmp"
qrCodes="/data/qrCodes"
jobs="/data/jobs"
database="ovp"
mysqlhost="localhost"
mysqluser="processvideo"
mysqlpass="processvideopassword"
log="/data/logs/processVideo.log"
mysql=$(command -v mysql)
sha256sum=$(command -v sha256sum)
cut=$(command -v cut)
qrencode=$(command -v qrencode)
curl=$(command -v curl)
awk=$(command -v awk)
find=$(command -v find)
tail=$(command -v tail)
ip=$(command -v ip)
cat=$(command -v cat)
interface="eth0"
rm=$(command -v rm)
ffmpeg=$(find /data/ffmpeg -type f -name ffmpeg)
threads="16" #Number of threads to use in video conversion. This is per-process.
id=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)
[[ -z $id ]] && id=$($ip -4 addr show $interface | $awk -F'[ /]+' '/global/ {print $3}')

#Make all the directories if they aren't there.
mkdir -p $videoDir
mkdir -p $tmpDir
mkdir -p $qrCodes
mkdir -p $jobs

processupload() {


local job="$1"
if [[ -z $job ]]; then
    #No job file passed? Exit.
    echo "No job passed" >> $log
    return 1
fi

if [[ ! -e $job ]]; then
    #Job file does not exist? Exit.
    echo "$job does not exist"
    return 1
fi

#After verifying that $job is not empty, and the file exists, source it.
source $job


if [[ -z $file ]]; then
    #No file passed? Exit.
    echo "No file passed" >> $log
    return 1
fi


if [[ -z $vTitle ]]; then
    #No vTitle passed? Exit.
    echo "No vTitle passed" >> $log
    return 1
fi


if [[ -z $uID ]]; then
    #No user passed? Exit.
    echo "No uID passed" >> $log
    return 1
fi


#Troubleshooting line
echo "file=\"$file\" vTitle=\"$vTitle\" uID=\"$uID\"" >> $log


if [[ ! -e $file ]]; then
    #File doesn't exist? Exit.
    echo "File doesn't exist" >> $log
    return 1
fi

if [[ -z $mysql ]]; then
    #mysql not present.
    echo "mysql not available" >> $log
    return 1
fi

if [[ -z $sha256sum ]]; then
    echo "sha256sum not available" >> $log
    return 1
fi

if [[ -z $cut ]]; then
    echo "cut not available" >> $log
    return 1
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
        $ffmpeg -loglevel quiet -threads $threads -i "$file" -vcodec copy -acodec copy "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            extension="mp4"
            file="${tmpDir}/${filename}.${extension}"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -loglevel quiet -threads $threads -i \"$file\" -vcodec copy -acodec copy \"${tmpDir}/${filename}.mp4\"" >> $log
            rm -f "${tmpDir}/${filename}.mp4" > /dev/null 2>&1
            return 1
        fi

    elif [[ "$extension" == "avi" || "$extension" == "AVI" ]]; then
        # avi conversion command here.
        $ffmpeg -loglevel quiet -threads $threads -i "$file" "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            extension="mp4"
            file="${tmpDir}/${filename}.${extension}"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -loglevel quiet -threads $threads -i \"$file\" \"${tmpDir}/${filename}.mp4\"" >> $log
            rm -f "${tmpDir}/${filename}.mp4" > /dev/null 2>&1
            return 1
        fi

    else
        # Best shot here.
        $ffmpeg -loglevel quiet -threads $threads -i "$file" "${tmpDir}/${filename}.mp4"
        if [[ $? -eq 0 ]]; then
            $rm -f $file
            extension="mp4"
            file="${tmpDir}/${filename}.${extension}"
        else
            echo "Error converting file. Command was:" >> $log
            echo "$ffmpeg -loglevel quiet -threads $threads -i \"$file\" \"${tmpDir}/${filename}.mp4\"" >> $log
            rm -f "${tmpDir}/${filename}.mp4" > /dev/null 2>&1
            return 1
        fi
    fi

fi



#hash the file.
sum=$( $sha256sum $file | $cut -d' ' -f1)

if [[ "${#sum}" != "64" ]]; then
    #Sum is not 64 characters? Exit.
    echo "sum is not 64 characters, was ${#sum}" >> $log
    return 1
else
    vID="${sum}.${extension}"
fi


#Store it into the DB.
$mysql $options "INSERT INTO Videos (vID,vTitle) VALUES (\"${vID}\",\"${vTitle}\")"
result=$?
if [[ "$result" != "0" ]]; then
    #Insert failed? Exit.
    echo "Insert into Videos failed, exit code $result : INSERT INTO Videos (vID,vTitle) VALUES (\"${vID}\",\"${vTitle}\")" >> $log
    return 1
fi
$mysql $options "INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${vID}\",\"${uID}\")"
result=$?
if [[ "$result" != "0" ]]; then
    echo "Insert into UserVideoAssoc failed, exit code $result : INSERT INTO UserVideoAssoc (vID,uID) VALUES (\"${vID}\",\"${uID}\")" >> $log
    #Insert failed? Exit.
    return 1
fi


#Move the file into place.
mv $file ${videoDir}/${vID}
#echo "mv $file ${videoDir}/${vID}" >> $log
if [[ "$?" != 0 ]]; then
    #Move failed? Exit.
    echo "Move failed for $file" >> $log
    return 1
else
    #Generate a QR code for the link.
    if [[ -e ${qrCodes}/${sum}.png ]]; then
        rm -f ${qrCodes}/${sum}.png
    fi
    $qrencode -o ${qrCodes}/${sum}.png "https://${domainName}/player.php?v=${vID}"
    if [[ "$?" != 0 ]]; then
        echo "QR generation failed for \"https://${domainName}/player.php?v=${vID}\"" >> $log
        return 1
    fi
fi

#If we've got this far, we're OK to delete the job file.
rm -f $job

#cleanup.
unset file
unset vTitle
unset uID
unset job

}


while true; do
    #This loop just does one job per loop to keep things simple.
    for job in $($find /data/jobs -type f -name '*.job' | $tail -n 1)
    do
        #Check if there is a lock file or not. If so, break.
        [[ -e ${job}.lock ]] && break
        #If we are here, there is no lock file. So try to write the lock file, overwrite any existing data in the file.
        $echo $id > ${job}.lock
        #Now we check to see if we successfully aquired the lock or not. If we did not, break.
        [[ $($cat ${job}.lock) != $id ]] && break

        #If we got this far, we can process the job because we have the lock.
        processupload "$job"
    done
    sleep 7
done


