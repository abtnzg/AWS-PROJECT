#!/bin/bash

# Script pour importer les ressources AWS existantes dans l'état Terraform
# Execute this from Terraform-infrastr directory

set -e

ENVIRONMENT=${1:-dev}
REGION=us-east-1

echo "===========================================" 
echo "Importing AWS resources to Terraform state"
echo "Environment: $ENVIRONMENT"
echo "==========================================="

cd "Terraform-infrastr"

# Sélectionner le workspace
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# 1. Import ALB (Application Load Balancer)
ALB_NAME="aws-project-alb-${ENVIRONMENT}"
echo "Importing ALB: $ALB_NAME"
terraform import "module.alb.aws_lb.this" "$ALB_NAME"

# 2. Import Target Group
echo "Importing Target Group"
TARGET_GROUP_NAME="${ALB_NAME}-tg"
# Get target group ARN
TG_ARN=$(aws elbv2 describe-target-groups --region $REGION --query "TargetGroups[?TargetGroupName=='${TARGET_GROUP_NAME}'].TargetGroupArn" --output text)
if [ -n "$TG_ARN" ]; then
  terraform import "module.alb.aws_lb_target_group.this" "$TG_ARN"
else
  echo "⚠️ Target Group not found: $TARGET_GROUP_NAME"
fi

# 3. Import EKS Cluster Role
EKS_CLUSTER_ROLE="aws-project-eks-${ENVIRONMENT}-cluster-role"
echo "Importing EKS Cluster Role: $EKS_CLUSTER_ROLE"
terraform import "module.eks.aws_iam_role.eks_cluster_role" "$EKS_CLUSTER_ROLE"

# 4. Import EKS Node Role
EKS_NODE_ROLE="aws-project-eks-${ENVIRONMENT}-node-role"
echo "Importing EKS Node Role: $EKS_NODE_ROLE"
terraform import "module.eks.aws_iam_role.eks_node_role" "$EKS_NODE_ROLE"

# 5. Import External DNS Policy
POLICY_NAME="external-dns-route53-policy"
echo "Importing External DNS Policy: $POLICY_NAME"
# Get policy ARN
POLICY_ARN=$(aws iam list-policies --region $REGION --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn" --output text)
if [ -n "$POLICY_ARN" ]; then
  terraform import "module.external_dns.aws_iam_policy.external_dns" "$POLICY_ARN"
else
  echo "⚠️ Policy not found: $POLICY_NAME"
fi

echo ""
echo "==========================================="
echo "✅ Import complete. Run 'terraform plan' to verify"
echo "==========================================="
