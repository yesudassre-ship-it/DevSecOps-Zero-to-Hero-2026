#!/bin/bash

MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "$MY_IP"

REGION="us-east-1"
SG_NAME="ssh-my-system"

# Check whether Security Group exists in the default VPC

SG_ID=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters "Name=group-name,Values=$SG_NAME" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

if [[ "$SG_ID" != "None" && -n "$SG_ID" ]]; then
    echo "Security Group exists: $SG_NAME"
    echo "Security Group ID: $SG_ID"
else
    echo "Security Group does not

# Create only if it does not exist  
if [ $SG_GROUP_NAME != "$SG_NAME" ]; then
    SG_NAME=$(aws ec2 create-security-group \
      --group-name "$SG_NAME" \
      --description "Allow SSH from my system IPv4 only" \
      --vpc-id "$VPC_ID" \
      --region "$REGION" \
      --query 'groups' \
      --output text)

  echo "$SG_GROUP created for ssh login from $MY_IP alone"
 else
   echo "$SG_GROUP exits and can be accessble  from $MY_IP alone"
fi   

# Authorize SSH from your public IPv4

SG_GROUP_OP=$(aws ec2 authorize-security-group-ingress \
  --group-id "$SG_GROUP" \
  --protocol tcp \
  --port 22 \
  --cidr "${MY_IP}/32" \
  --region "$REGION")
  
echo "This $SG_GROUP Security Group : $SG_GROUP_OP"