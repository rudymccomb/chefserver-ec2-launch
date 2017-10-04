#!/bin/bash

# Global Settings
account="dev"
region="us-west-1"

# Instance settings
image_id="ami-2d5c6d4d" # ubuntu 14.04
ssh_key_name="rudy-mbp"
instance_type="c4.large"
subnet_id="subnet-aedfdcca"
vpc="vpc-ccaghjk"
AWS_IAM_INSTANCE_PROFILE="Name=chef-server"
AWS_SECURITY_GROUP_IDS="sg-0d3dhf6a"
SSH_KEY='~/.ssh/rudy-mbp.pem'
EC2_USER='ubuntu'
#user_data_file=$(mktemp /tmp/user-data-XXXX.txt)
user_data_file="/tmp/user_data_file.sh"
#iam_profile="chef-server"
root_vol_size=20
count=1

# Tags
tags_Name="my-test-instance"
tags_Owner="rudymccomb"
tags_ApplicationRole="ChefServer"
tags_Cluster="Test Cluster"
tags_Environment="dev"
tags_OwnerEmail="rudy@thnkbig.com"
tags_Project="ChefServer Bootstrap"
tags_BusinessUnit="DevOps"
tags_SupportEmail="rudy@thnkbig.com"
tags_OwnerGroups="DevOps"

#cat <<EOF > ~/tmp/print.sh
cat << EOF > /tmp/user_data_file.sh
#!/bin/bash
echo \$PWD
echo $PWD
EOF

START_TIME=$(date)

echo 'creating instance...'
id=$(aws --profile $account  --region $region ec2 run-instances --image-id $image_id --security-group-ids $AWS_SECURITY_GROUP_IDS --count $count --instance-type $instance_type --key-name $ssh_key_name --subnet-id $subnet_id --iam-instance-profile $AWS_IAM_INSTANCE_PROFILE --user-data file://$user_data_file --associate-public-ip-address  --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": $root_vol_size } } ]" --query 'Instances[*].InstanceId' --output text)

#--iam-instance-profile Name=$AWS_IAM_INSTANCE_PROFILE
#--security-group-ids $AWS_SECURITY_GROUP_IDS

echo "$id created using profile"
echo "Instance ID is $id. Waiting for the instance to run."

# If we try and exit at any point, make sure to terminate the instance
trap 'echo "" && echo "Please wait - terminating instances." && aws ec2 terminate-instances --instance-ids $id && exit' SIGINT

aws ec2 wait instance-running --instance-ids $id &&

# Retrieve the public IP
IP=$(aws ec2 describe-instances --instance-ids $id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
# @todo make sure IP retrieved successfully
echo "Instance is running, public IP is $IP. Waiting for instance to be ready... (this might take a while)"

# tag it

echo "tagging $id..."

aws --profile $account --region $region ec2 create-tags --resources $id --tags Key=Name,Value="$tags_Name" Key=Owner,Value="$tags_Owner"  Key=ApplicationRole,Value="$tags_ApplicationRole" Key=Cluster,Value="$tags_Cluster" Key=Environment,Value="$tags_Environment" Key=OwnerEmail,Value="$tags_OwnerEmail" Key=Project,Value="$tags_Project" Key=BusinessUnit,Value="$tags_BusinessUnit" Key=SupportEmail,Value="$tags_SupportEmail" Key=OwnerGroups,Value="$tags_OwnerGroups"

echo "storing instance details..."
# store the data
aws --profile $account --region $region ec2 describe-instances --instance-ids $id > instance-details.json

echo "create termination script"
echo "#!/bin/bash" > terminate-instance.sh
echo "aws --profile $account --region $region ec2 terminate-instances --instance-ids $id" >> terminate-instance.sh
chmod +x terminate-instance.sh

# Polls EC2 every 15 seconds for all checks to pass, then opens the tunnel
#aws ec2 wait instance-status-ok --instance-ids $id && echo "Instance is ready. Opening SSH tunnel." && ssh -p 22 -N $EC2_USER@$IP -i $SSH_KEY
# ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"
#
#echo "remove the servers entry from ~/.ssh/known_hosts"
#ssh-keygen -R $IP

echo "Start: $START_TIME"
echo "Now:   $(date)"
echo Done.

#currently hangs
#add this when script is done
#echo "waiting to login to instance"
# Polls EC2 every 15 seconds for all checks to pass, then opens the tunnel
#aws ec2 wait instance-status-ok --instance-ids $id && echo "Instance is ready. Opening SSH tunnel." && ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_KEY -N $EC2_USER@$IP

#echo "Hello World"
#exit 0
