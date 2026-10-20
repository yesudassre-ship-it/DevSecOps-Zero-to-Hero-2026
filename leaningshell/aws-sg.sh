#!/bin/bash

set -e

REGION="us-east-1"
SG_NAME="ssh-my-system"

# Get public IPv4
MY_IP=$(curl -fsS https://checkip.amazonaws.com | tr -d '[:space:]')
echo "My Public IP: $MY_IP"

# Find default VPC
VPC_ID=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)

if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then
  echo "ERROR: Default VPC not found in $REGION"
  exit 1
fi

echo "Default VPC ID: $VPC_ID"

# Check whether Security Group exists in the default VPC
SG_GROUP=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters \
    "Name=group-name,Values=$SG_NAME" \
    "Name=vpc-id,Values=$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

# Create only if it does not exist
if [[ "$SG_GROUP" == "None" || -z "$SG_GROUP" ]]; then

  SG_GROUP=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Allow SSH from my system IPv4 only" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query 'GroupId' \
    --output text)

  echo "Created Security Group: $SG_GROUP"

else
  echo "Security Group already exists: $SG_GROUP"
fi

# Check whether SSH rule already exists
SSH_RULE=$(aws ec2 describe-security-groups \
  --group-ids "$SG_GROUP" \
  --region "$REGION" \
  --query "SecurityGroups[0].IpPermissions[?IpProtocol=='tcp' && FromPort==\`22\` && ToPort==\`22\`].IpRanges[?CidrIp=='${MY_IP}/32'].CidrIp | [0][0]" \
  --output text)

# Add SSH rule only if missing
if [[ "$SSH_RULE" == "None" || -z "$SSH_RULE" ]]; then
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_GROUP" \
    --protocol tcp \
    --port 22 \
    --cidr "${MY_IP}/32" \
    --region "$REGION"

  echo "SSH access added for ${MY_IP}/32"
else
  echo "SSH access already exists for ${MY_IP}/32"
fi

echo "Security Group ID: $SG_GROUP"
