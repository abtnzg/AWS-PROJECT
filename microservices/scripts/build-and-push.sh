#!/bin/bash

# Build and push Docker images to ECR
# Usage: ./build-and-push.sh <aws-account-id> <region> <image-tag>

set -e

AWS_ACCOUNT_ID=${1:-}
AWS_REGION=${2:us-east-1}
IMAGE_TAG=${3:-latest}
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Usage: ./build-and-push.sh <aws-account-id> [region] [image-tag]"
  exit 1
fi

echo "=========================================="
echo "Building and pushing Docker images to ECR"
echo "=========================================="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "ECR Registry: $ECR_REGISTRY"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Services to build
SERVICES=("api-gateway" "user-service" "product-service" "order-service")

for SERVICE in "${SERVICES[@]}"; do
  echo ""
  echo "Building $SERVICE..."
  
  # Create ECR repository if it doesn't exist
  echo "Checking ECR repository for $SERVICE..."
  if ! aws ecr describe-repositories --repository-names $SERVICE --region $AWS_REGION &> /dev/null; then
    echo "Creating ECR repository for $SERVICE..."
    aws ecr create-repository --repository-name $SERVICE --region $AWS_REGION
  fi
  
  # Build Docker image
  echo "Building Docker image for $SERVICE..."
  docker build -t $SERVICE:$IMAGE_TAG ./$SERVICE
  
  # Tag image for ECR
  docker tag $SERVICE:$IMAGE_TAG $ECR_REGISTRY/$SERVICE:$IMAGE_TAG
  docker tag $SERVICE:$IMAGE_TAG $ECR_REGISTRY/$SERVICE:latest
  
  # Push to ECR
  echo "Pushing $SERVICE to ECR..."
  docker push $ECR_REGISTRY/$SERVICE:$IMAGE_TAG
  docker push $ECR_REGISTRY/$SERVICE:latest
  
  echo "✅ $SERVICE pushed successfully!"
done

echo ""
echo "=========================================="
echo "✅ All images built and pushed successfully!"
echo "=========================================="
echo ""
echo "ECR Images:"
for SERVICE in "${SERVICES[@]}"; do
  echo "  - $ECR_REGISTRY/$SERVICE:$IMAGE_TAG"
done
