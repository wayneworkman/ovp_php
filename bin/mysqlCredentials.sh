#!/bin/bash




#This gets the endpoint of an AWS RDS database with the DBInstanceIdentifier "ovp" and puts the Endpoint of it into the vars.php file properly.
databaseEndpointName="ovp"
databaseEndpoint=$(aws rds describe-db-instances | jq ".DBInstances[] | select(.DBInstanceIdentifier == \"${databaseEndpointName}\")" | jq '.Endpoint.Address')
databaseEndpoint="${databaseEndpoint%\"}"
databaseEndpoint="${databaseEndpoint#\"}"


mysqlUser="processvideo"
mysqlPass="processvideopassword"
mysqlHost="ServerNameGoesHere"
database="$databaseEndpoint"
