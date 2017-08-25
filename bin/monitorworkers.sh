#!/bin/bash



#Variables.
workers="/data/conversionNodes"

mkdir -p $workers

while true; do
    #This loops through all the worker files and checks for a monitoring process for each found.
    #If one isn't found for it, one gets made and backgrounded.
    for worker in $(find $workers -type f)
    do
        ps -p "$(pidof -x monitorExactWorker.sh)" -o args | grep $worker
        [[ $? == 1 ]] && /data/scripts/monitorExactWorker.sh $worker
    done
    sleep 7
done


