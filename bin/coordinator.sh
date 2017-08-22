#!/bin/bash




while true; do
    #This loop just does one job per loop to keep things simple.
    for job in $($find /data/jobs -type f -name '*.job')
    do
        #Check if there is a lock file or not. If so, continue.
        [[ -e ${job}.lock ]] && continue
        #If we are here, there is no lock file. So try to write the lock file, overwrite any existing data in the file.
        $echo $id > ${job}.lock
        #Now we check to see if we successfully aquired the lock or not. If we did not, break.
        [[ $($cat ${job}.lock) != $id ]] && continue

        #If we got this far, we can process the job because we have the lock.
        processupload "$job"
    done
    sleep 7
done


