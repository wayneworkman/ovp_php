#!/bin/bash



#Variables.
workers="/data/conversionNodes"
jobs="/data/jobs"

mkdir -p $workers

while true; do

    #This loops through all the worker files and checks for a monitoring process for each found.
    #If one isn't found for it, one gets made and backgrounded.
    for worker in $(find $workers -type f)
    do
        worker=$(basename $worker)
        ps -p "$(pidof -x monitorExactWorker.sh)" -o args | grep $worker > /dev/null 2>&1
        [[ $? == 1 ]] && /data/scripts/monitorExactWorker.sh $worker
    done


    #If a job has a lock file that is not an actual worker we know of, delete the lock file.
    for lock in $(find $jobs -type f -name '*.lock')
    do
        lockID=$(cat $lock | head -n 1)
        if [[ ! -e ${workers}/${lockID} ]]; then
            rm -f $lock
        fi
    done


    #How often to do this stuff.
    sleep 7

done


