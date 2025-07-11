$AMI_ID=$1

set -x 

while true; do
  clear
  aws ec2 get-console-output --instance-id ${AMI_ID} 
  sleep 5
done
