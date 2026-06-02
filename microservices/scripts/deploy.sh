#!/bin/bash

# Deploy microservices to Kubernetes cluster
# Usage: ./deploy.sh <aws-account-id> <environment> <namespace>

set -e

AWS_ACCOUNT_ID=${1:-}
ENVIRONMENT=${2:-dev}
NAMESPACE=${3:-microservices}

if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Usage: ./deploy.sh <aws-account-id> [environment] [namespace]"
  exit 1
fi

echo "=========================================="
echo "Deploying microservices to Kubernetes"
echo "=========================================="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "Environment: $ENVIRONMENT"
echo "Namespace: $NAMESPACE"
echo ""

# Update Kubernetes manifests with AWS Account ID
echo "Updating Kubernetes manifests with AWS Account ID..."
sed -i "s/AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" k8s/*.yaml

# Create namespace if it doesn't exist
echo "Creating namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Label namespace for NetworkPolicy
kubectl label namespace $NAMESPACE name=$NAMESPACE --overwrite

# Apply MySQL configuration
echo "Deploying MySQL..."
kubectl apply -f k8s/01-mysql.yaml

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=300s

# Apply services
echo "Deploying microservices..."
kubectl apply -f k8s/02-services.yaml

# Wait for services to be ready
echo "Waiting for services to be ready..."
kubectl wait --for=condition=ready pod -l app in (api-gateway,user-service,product-service,order-service) -n $NAMESPACE --timeout=300s

# Apply Ingress and HPA
echo "Deploying Ingress and HPA..."
kubectl apply -f k8s/03-ingress-hpa.yaml

echo ""
echo "=========================================="
echo "✅ Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Get service endpoints:"
echo "  kubectl get svc -n $NAMESPACE"
echo ""
echo "Get pod status:"
echo "  kubectl get pods -n $NAMESPACE"
echo ""
echo "Get ingress status:"
echo "  kubectl get ingress -n $NAMESPACE"
echo ""
echo "View API Gateway logs:"
echo "  kubectl logs -f -l app=api-gateway -n $NAMESPACE"
