#!/bin/bash

# Setup ArgoCD on EKS cluster
# Usage: ./setup-argocd.sh <cluster-name> <region>

set -e

CLUSTER_NAME=${1:-aws-project-eks-dev}
AWS_REGION=${2:us-east-1}
NAMESPACE="argocd"
DOMAIN="205474062795.realhandsonlabs.net"

echo "=========================================="
echo "Setting up ArgoCD on EKS"
echo "=========================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $AWS_REGION"
echo ""

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Create namespace
echo "Creating ArgoCD namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repository
echo "Adding ArgoCD Helm repository..."
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD
echo "Installing ArgoCD with Helm..."
helm install argocd argocd/argo-cd \
  --namespace $NAMESPACE \
  --values - <<EOF
server:
  service:
    type: LoadBalancer
  config:
    url: https://argocd.$DOMAIN

configs:
  cm:
    application.instanceLabelKey: argocd.argoproj.io/instance

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

controller:
  replicas: 1
EOF

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n $NAMESPACE

# Get initial admin password
echo ""
echo "=========================================="
echo "ArgoCD Installation Complete!"
echo "=========================================="
echo ""

# Get LoadBalancer hostname
ARGOCD_URL=$(kubectl get svc argocd-server -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
ADMIN_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)

echo "ArgoCD URL: https://$ARGOCD_URL"
echo "Admin Username: admin"
echo "Admin Password: $ADMIN_PASSWORD"
echo ""
echo "Access ArgoCD at: https://$ARGOCD_URL"
echo ""
echo "First login steps:"
echo "1. argocd login $ARGOCD_URL"
echo "2. argocd account update-password --account admin --new-password <new-password>"
echo ""
echo "Add GitHub repository:"
echo "argocd repo add https://github.com/abtnzg/AWS-PROJECT \\"
echo "  --username <github-username> \\"
echo "  --password <github-token>"
