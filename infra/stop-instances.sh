#/!bin/bash
#for stop instances- database - backend - webserver

database=i-0829d2f291e808c37
backend=i-06f99dec69d31bcf8
webserver=i-001690ed722219bf6

stopserver=($webserver $backend $database)

for stop in ${stopserver[@]}
do

  aws ec2 stop-instances --instance-ids $stop
  sleep 60s

done

