#!/bin/bash

# Get microservices status
# Usage: ./status.sh [namespace]

set -e

NAMESPACE=${1:-microservices}

echo "=========================================="
echo "Microservices Status"
echo "=========================================="
echo ""

echo "Namespace: $NAMESPACE"
echo ""

echo "Pods:"
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "Services:"
kubectl get svc -n $NAMESPACE

echo ""
echo "Ingress:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "HPA Status:"
kubectl get hpa -n $NAMESPACE

echo ""
echo "Deployments:"
kubectl get deployments -n $NAMESPACE -o wide

echo ""
echo "Events:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'
