#!/bin/bash



# Objectives:
#     * Keep desired count at zero when there are no jobs.
#     * Once started, Instances are left running for 50 minutes unless they are processing a job.
#     * Instances doing a job are marked as protected.
#     * Instances not doing a job are not protected.



#### Monitoring nodes, deciding when to terminate.
# For each worker file found, background a script to monitor it for the rest of it's life.
# it should first be allowed to run for 50 minutes. After this, it's evaluated once an hour.
# If on an evaluation it is not processing a job, it is terminated and the desired count is decreased by one.
# Check if such a script with such arguments is already running or not, if so, don't launch another.


#### Monitoring jobs, deciding when to scale-out.
# If there are no workers, and there are jobs, scale out by one.
# If there are five or more jobs without locks, sale out by one.


#### Disaster control.
# If a job is locked for over 2 hours, terminate the instance processing the job and move the job to problemJobs.
# This would be a job-lock monitoring script that is backgrounded.
# Check if such a script with such arguments is already running or not, if so, don't launch another.


#### This node disappears control.
# If this node has problems or this script dies, something must set the desired count to zero.
# Could be lambda, could be the conversion nodes themselves.



cooldown=300 #wait peroid after scaling out in seconds.
groupName=$(aws autoscaling describe-auto-scaling-groups | jq .AutoScalingGroups[].AutoScalingGroupName | grep ConversionGroup)

while true; do
    desiredCapacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $groupName | jq '.AutoScalingGroups[0] .DesiredCapacity')


    #This loop goes through each job file.
    for job in $(find /data/jobs -type f -name '*.job')
    do

        #Check to see if there's not a lock for this job.
        if [[ ! -e ${job}.lock ]]; then
            #Here, we have a job without a lock. If desiredCapacity is currently 0, we need to bump it to one.
            if [[ "$desiredCapacity" == "0" ]]; then
                aws autoscaling set-desired-capacity --auto-scaling-group-name $groupName --desired-capacity 1
                sleep $cooldown
            else
                #Here, we have a non-zero DesiredCapacity, which means 1 or greater.
                #We need to figure out if we should increase DesiredCapacity or not based on how many jobs without locks we have.
                echo "Do decision here"
            fi
        fi

    done
    sleep 7
done





