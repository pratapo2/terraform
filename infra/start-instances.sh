#/!bin/bash
# For Start Instances- Database - Backend - webserver

database=i-0829d2f291e808c37
backend=i-06f99dec69d31bcf8
webserver=i-001690ed722219bf6

startserver=("$database" "$backend" "$webserver")


for start in ${startserver[@]}
do
  aws ec2 start-instances --instance-ids $start
  sleep 120s
done


