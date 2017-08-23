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



while true; do
    #This loop just does one job per loop to keep things simple.
    for job in $($find /data/jobs -type f -name '*.job')
    do




    done
    sleep 7
done



#Notes:

#This gets current desired capacity of an autoscaling group.
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names Perpetuum-Conversion-Nodes-ConversionGroup-1Q2DBEDN3Q5S9 | jq '.AutoScalingGroups[0] .DesiredCapacity'


aws autoscaling terminate-instance-in-auto-scaling-group --instance-id <value> --should-decrement-desired-capacity
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names Perpetuum-Conversion-Nodes-ConversionGroup-1Q2DBEDN3Q5S9









