#!/bin/bash

MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "$MY_IP"

REGION="us-east-1"

VPC_ID=$(aws ec2 describe-vpcs \
  --region "us-east-1" \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)
echo "Defauly VPC ID: $VPC_ID"

SG_GROUP_NAME=(aws ec2 describe-security-groups \
  --region $REGION \
  --filters "Name=group-name,Values=ssh-my-system" \
  --query 'SecurityGroups[*].[GroupId,GroupName,VpcId]' \
  --output table)

 if ($SG_GROUP_NAME=!ssh-my-system) then
SG_GROUP_NAME=ssh-my-system
SG_GROUP=$(aws ec2 create-security-group \
  --group-name "$SG_NAME" \
  --description "Allow SSH from my system IPv4 only" \
  --vpc-id "$VPC_ID" \
  --region "$REGION" \
  --query 'groups' \
  --output text)
  echo "$SG_GROUP created for ssh login from $MY_IP alone"
 else
   echo "$SG_GROUP exits and can be accessble  from $MY_IP alone"
  exit()
fi   

SG_GROUP_OP=$(aws ec2 authorize-security-group-ingress \
  --group-id "$SG_GROUP" \
  --protocol tcp \
  --port 22 \
  --cidr "${MY_IP}/32" \
  --region "$REGION")
  
echo "This $SG_GROUP Security Group : $SG_GROUP_OP"