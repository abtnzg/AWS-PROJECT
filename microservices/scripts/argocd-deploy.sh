#!/bin/bash

# Deploy microservices using ArgoCD
# Usage: ./argocd-deploy.sh <environment> <image-tag>

set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
ARGOCD_NS="argocd"
APP_NAME="microservices-$ENVIRONMENT"

echo "=========================================="
echo "Deploying Microservices with ArgoCD"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Image Tag: $IMAGE_TAG"
echo "Application: $APP_NAME"
echo ""

# Check if ArgoCD CLI is available
if ! command -v argocd &> /dev/null; then
  echo "Installing ArgoCD CLI..."
  curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  chmod +x /usr/local/bin/argocd
fi

# Get ArgoCD server
ARGOCD_SERVER=$(kubectl get svc argocd-server -n $ARGOCD_NS -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "localhost:8080")
echo "ArgoCD Server: $ARGOCD_SERVER"

# Login to ArgoCD (if token provided)
if [ -n "$ARGOCD_TOKEN" ]; then
  echo "Logging in to ArgoCD..."
  argocd login $ARGOCD_SERVER --auth-token $ARGOCD_TOKEN --insecure
fi

# Apply ArgoCD applications
echo "Applying ArgoCD applications..."
kubectl apply -f ./argocd/applications.yaml

# Sync application
echo "Syncing ArgoCD application: $APP_NAME..."
argocd app sync $APP_NAME --auth-token $ARGOCD_TOKEN --insecure

# Wait for sync to complete
echo "Waiting for application to sync..."
argocd app wait $APP_NAME --auth-token $ARGOCD_TOKEN --insecure --sync

# Get application status
echo ""
echo "=========================================="
echo "Application Status"
echo "=========================================="
argocd app get $APP_NAME --auth-token $ARGOCD_TOKEN --insecure

echo ""
echo "Check pod status:"
echo "  kubectl get pods -n microservices"
echo ""
echo "View application diff:"
echo "  argocd app diff $APP_NAME"
