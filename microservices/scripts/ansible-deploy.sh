#!/bin/bash

# Deploy microservices using Ansible
# Usage: ./ansible-deploy.sh <environment> <image-tag>

set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
ANSIBLE_DIR="./ansible"

echo "=========================================="
echo "Deploying Microservices with Ansible"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
  echo "Installing Ansible..."
  pip install ansible-core
fi

# Install Ansible collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r $ANSIBLE_DIR/requirements.yaml

# Run deployment playbook
echo "Running deployment playbook..."
ansible-playbook \
  -i $ANSIBLE_DIR/inventory.yaml \
  $ANSIBLE_DIR/deploy-microservices.yaml \
  -e "deploy_env=$ENVIRONMENT" \
  -e "image_tag=$IMAGE_TAG" \
  -v

# Verify deployment
echo ""
echo "Verifying deployment..."
ansible-playbook \
  -i $ANSIBLE_DIR/inventory.yaml \
  $ANSIBLE_DIR/verify-deployment.yaml \
  -v

echo ""
echo "=========================================="
echo "✅ Deployment completed with Ansible!"
echo "=========================================="
