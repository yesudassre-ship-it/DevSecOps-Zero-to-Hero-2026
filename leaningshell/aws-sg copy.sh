#!/bin/bash

MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "$MY_IP"

REGION="us-east-1"

VPC_ID=$(aws ec2 describe-vpcs \
  --region "us-east-1" \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)

if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then
  echo "ERROR: Default VPC not found in $REGION"
  exit 1
fi

echo "Defauly VPC ID: $VPC_ID"

# Check whether Security Group exists in the default VPC

SG_NAME=ssh-my-system
SG_GROUP_NAME=(aws ec2 describe-security-groups \
  --region $REGION \
  --filters "Name=group-name,Values=$SG_NAME" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

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