#!/bin/bash

# À exécuter localement après avoir configuré vos credentials AWS
# Exemple: export AWS_ACCESS_KEY_ID="..." AWS_SECRET_ACCESS_KEY="..."

set -e

ENVIRONMENT=${1:-dev}
REGION="us-east-1"
CLUSTER_NAME="aws-project-eks-${ENVIRONMENT}"
ALB_NAME="aws-project-alb-${ENVIRONMENT}"

echo "=========================================="
echo "Importing existing AWS resources to state"
echo "=========================================="

cd Terraform-infrastr

# Initialiser avec le backend configuré
terraform init -backend-config="inventories/${ENVIRONMENT}/backend.hcl" 2>/dev/null || true

# 1. Importer ALB
echo "➤ Importing ALB: $ALB_NAME"
terraform import -auto-approve "module.alb.aws_lb.this" "$ALB_NAME" || echo "⚠️ ALB not found or already imported"

# 2. Importer Target Group
echo "➤ Importing Target Group"
TG_ARN=$(terraform output -raw alb_target_group_arn 2>/dev/null || echo "")
if [ -z "$TG_ARN" ]; then
  echo "⚠️ Need to get target group ARN manually from AWS console"
  echo "   Run: aws elbv2 describe-target-groups --region $REGION --names ${ALB_NAME}-tg"
fi

# 3. Importer IAM Roles
echo "➤ Importing EKS Cluster Role"
terraform import -auto-approve "module.eks.aws_iam_role.eks_cluster_role" "${CLUSTER_NAME}-cluster-role" || echo "⚠️ Role not found or already imported"

echo "➤ Importing EKS Node Role"
terraform import -auto-approve "module.eks.aws_iam_role.eks_node_role" "${CLUSTER_NAME}-node-role" || echo "⚠️ Role not found or already imported"

# 4. Importer External DNS Policy
echo "➤ Importing External DNS Policy"
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='external-dns-route53-policy'].Arn" --output text 2>/dev/null || echo "")
if [ -n "$POLICY_ARN" ]; then
  terraform import -auto-approve "module.external_dns.aws_iam_policy.external_dns" "$POLICY_ARN" || echo "⚠️ Policy already imported"
else
  echo "⚠️ Policy not found"
fi

echo ""
echo "=========================================="
echo "✅ Import attempt complete"
echo "Run 'terraform plan' to check for differences"
echo "=========================================="
