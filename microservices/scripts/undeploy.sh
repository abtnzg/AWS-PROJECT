#!/bin/bash

# Undeploy microservices from Kubernetes cluster
# Usage: ./undeploy.sh [namespace]

set -e

NAMESPACE=${1:-microservices}

echo "=========================================="
echo "Undeploying microservices from Kubernetes"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo ""

# Confirm deletion
read -p "Are you sure you want to delete all resources in namespace $NAMESPACE? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

echo "Deleting namespace $NAMESPACE..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true

echo ""
echo "=========================================="
echo "✅ Undeploy completed!"
echo "=========================================="
