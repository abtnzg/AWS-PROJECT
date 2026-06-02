#!/bin/bash

# Deploy microservices using Helm
# Usage: ./helm-deploy.sh <environment> <image-tag>

set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
RELEASE_NAME="microservices"
NAMESPACE="microservices"
CHART_PATH="./helm/microservices-chart"
AWS_REGION="eu-west-1"

echo "=========================================="
echo "Deploying Microservices with Helm"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Image Tag: $IMAGE_TAG"
echo "Namespace: $NAMESPACE"
echo ""

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Label namespace
kubectl label namespace $NAMESPACE name=$NAMESPACE --overwrite

# Create values file
VALUES_FILE="/tmp/helm-values-$ENVIRONMENT.yaml"
cat > $VALUES_FILE <<EOF
global:
  environment: $ENVIRONMENT
  region: $AWS_REGION
  accountId: "205474062795"

apiGateway:
  image:
    tag: "$IMAGE_TAG"
userService:
  image:
    tag: "$IMAGE_TAG"
productService:
  image:
    tag: "$IMAGE_TAG"
orderService:
  image:
    tag: "$IMAGE_TAG"
EOF

# Install or upgrade Helm chart
echo "Installing/Upgrading Helm chart..."
helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --values $CHART_PATH/values.yaml \
  --values $VALUES_FILE \
  --wait \
  --timeout 5m

# Wait for deployments
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/api-gateway -n $NAMESPACE

# Get deployment status
echo ""
echo "=========================================="
echo "Deployment Status"
echo "=========================================="
kubectl get pods -n $NAMESPACE -o wide
echo ""
kubectl get svc -n $NAMESPACE
echo ""

# Get API Gateway endpoint
API_GATEWAY_IP=$(kubectl get svc api-gateway -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

echo "API Gateway: http://$API_GATEWAY_IP"
echo ""
echo "Test the API:"
echo "  curl http://$API_GATEWAY_IP/health"
echo ""
echo "View logs:"
echo "  kubectl logs -f deployment/api-gateway -n $NAMESPACE"
echo ""
echo "Rollback to previous release:"
echo "  helm rollback $RELEASE_NAME -n $NAMESPACE"
