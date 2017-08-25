#!/bin/bash


#The purpose of this script is to monitor aws ec2 instances within an autoscaling group, and was written for maximizing
#the benefit to cost of on-demand instances. If you don't use on-demand instances, this script still will work but it
#won't save you any money. The problem this script solves is the billing model of on-demand instances. For on-demand instances,
#if you use them for 5 minutes or 55 minutes, you are billed for one hour. In the case of autoscaling, if you have a scale-out,
#Then a scale in, then a scale-out again within one hour, you're billed for two hours worth of instances when in reality only
#a single hour has gone by. The solution? Simple. Don't let aws handle your scaling activities, write your own algorithm to do
#it for you. This script should be called when a new member of an autoscaling group is known of (because we need the instance ID).
#This script will sleep for 55 minutes, and then check to see if the isntance is doing anything or not (tied into OVP's job queuing system).
#If the server is doing nothing, this script will remove it from service and reduce the DesiredCount. If it's doing stuff, leave it
#and check it once an hour afterwards for the same thing (see if it's doing stuff). Through this script is an autoscaling member's only
#pathway to death.

#Variables.
workers="/data/conversionNodes"
jobs="/data/jobs"
aws=$(command -v aws)
log="/data/logs/monitorExactWorker.log"


id=$1
if [[ -z $id ]]; then
    #No id passed, exiting.
    exit
fi

echo "Began monitoring $id" >> $log



checks() {
    #In this function, the order of the checks matters.


    #If this node is processing a job, leave this node alive.
    for job in $(find /data/jobs -type f -name '*.lock')
    do
        if [[ "$(cat $job | head -n 1)" == "$id" ]]; then
            #Node is working, it must live. Exit this check.
            echo "$id is processing a video." >> $log
            return 0
        fi
    done

    #If there are jobs without locks, leave this node alive.
    if [[ $(ls ${jobs}/*.job | wc -l) > $(ls ${jobs}/*.lock | wc -l) ]]; then
        echo "There are jobs without locks, leaving $id" >> $log
        return 0
    else
        echo "All jobs have locks and they are not this node, terminating $id" >> $log
        $aws autoscaling terminate-instance-in-auto-scaling-group --instance-id $id --should-decrement-desired-capacity
        rm -f ${workers}/${id}
        exit
    fi

    #If there are no jobs, kill this node.
    if [[ $(ls ${jobs}/*.job | wc -l) == "0" ]]; then
        echo "There are no jobs, terminating node $id" >> $log
        $aws autoscaling terminate-instance-in-auto-scaling-group --instance-id $id --should-decrement-desired-capacity
        rm -f ${workers}/${id}
        exit
    fi


    #If this node isn't healthy, kill this node.
    if [[ $(aws autoscaling describe-auto-scaling-instances --instance-ids $id | jq .AutoScalingInstances[0].HealthStatus) != "HEALTHY" ]]; then
        echo "Node $id is not healthy, terminating." >> $log
        $aws autoscaling terminate-instance-in-auto-scaling-group --instance-id $id --should-decrement-desired-capacity
        rm -f ${workers}/${id}
        exit
    fi

}



sleep 3300 # 3300 seconds is 55 minutes. To maximize benefit of on-demand instances, they should always run for nearly an hour minimum.

while true; do
    checks
    #After the initial offset created by 55 minutes (always 5 minutes shy of an hour), then begin checking once per hour.
    sleep 3600
done





