#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AWS Project - Terraform Backend Bootstrap${NC}"
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: terraform is not installed${NC}"
    exit 1
fi

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: aws cli is not installed${NC}"
    exit 1
fi

# Verify AWS credentials
echo "Verifying AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials not configured${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✓ AWS Account: ${ACCOUNT_ID}${NC}"
echo ""

# Navigate to bootstrap directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Initializing Terraform bootstrap..."
terraform init

echo ""
echo -e "${YELLOW}Terraform Plan:${NC}"
terraform plan

echo ""
read -p "Do you want to create the backend resources? (yes/no): " -r CONFIRM

if [[ $CONFIRM == "yes" ]]; then
    echo ""
    echo -e "${YELLOW}Creating backend resources...${NC}"
    terraform apply -auto-approve
    echo ""
    echo -e "${GREEN}✓ Backend resources created successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Go to Terraform-infrastr directory"
    echo "2. Run: terraform init -backend-config=inventories/dev/backend.hcl"
    echo "3. Then proceed with normal Terraform workflow"
else
    echo -e "${RED}Bootstrap cancelled${NC}"
    exit 1
fi
