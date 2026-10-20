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

VPC_ID=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)
echo "Defauly VPC ID: $VPC_ID"

SG_NAME="ssh-my-system"

SG_GROUP=$(aws ec2 create-security-group \
  --group-name "$SG_NAME" \
  --description "Allow SSH from my system IPv4 only" \
  --vpc-id "$VPC_ID" \
  --region "$REGION" \
  --query 'groups' \
  --output text)

echo "Security Group ID: $SG_GROUP"

SG_GROUP_OP=$(aws ec2 authorize-security-group-ingress \
  --group-id "$SG_GROUP" \
  --protocol tcp \
  --port 22 \
  --cidr "${MY_IP}/32" \
  --region "$REGION")
  
echo "This $SG_GROUP Security Group : $SG_GROUP_OP"