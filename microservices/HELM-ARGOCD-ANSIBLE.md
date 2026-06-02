# Helm, ArgoCD, and Ansible CI/CD Architecture

Complete CI/CD pipeline for deploying microservices to AWS EKS with Helm, ArgoCD, and Ansible.

## 📋 Overview

### Components

```
┌─────────────────────────────────────────────────────────┐
│               GitHub Actions (CI/CD)                     │
│  - Build & Test                                         │
│  - Build & Push Docker images to ECR                    │
│  - Validate Helm charts                                 │
│  - Deploy with ArgoCD or Ansible                        │
│  - Run integration tests                                │
└─────────────┬───────────────────────────────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
    ▼                   ▼
┌─────────────┐   ┌──────────────┐
│   Helm      │   │   Ansible    │
│  - Package  │   │  - Orchestrate
│  - Release  │   │  - Verify
└─────────────┘   └──────────────┘
    │                   │
    └─────────┬─────────┘
              │
              ▼
      ┌──────────────┐
      │   ArgoCD     │
      │  - GitOps    │
      │  - Sync      │
      │  - Rollback  │
      └──────┬───────┘
             │
             ▼
      ┌──────────────┐
      │  EKS Cluster │
      │  - Dev env   │
      │  - Prod env  │
      └──────────────┘
```

## 🛠️ Technology Stack

- **Package Management:** Helm 3.12+
- **GitOps:** ArgoCD 2.8+
- **Infrastructure as Code:** Ansible 2.13+
- **Container Orchestration:** Kubernetes 1.27+
- **Cloud Provider:** AWS (EKS, ECR, EC2)
- **CI/CD:** GitHub Actions
- **Configuration Management:** Kustomize

## 📦 Directory Structure

```
microservices/
├── helm/
│   └── microservices-chart/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── namespace.yaml
│           ├── mysql.yaml
│           ├── api-gateway.yaml
│           ├── user-service.yaml
│           ├── product-service.yaml
│           ├── order-service.yaml
│           └── network-policy.yaml
├── argocd/
│   ├── 00-setup.yaml
│   ├── applications.yaml
│   └── argocd-config.yaml
├── ansible/
│   ├── inventory.yaml
│   ├── setup-argocd.yaml
│   ├── deploy-microservices.yaml
│   ├── verify-deployment.yaml
│   └── requirements.yaml
├── kustomize/
│   ├── base/
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
├── scripts/
│   ├── setup-argocd.sh
│   ├── helm-deploy.sh
│   ├── ansible-deploy.sh
│   └── argocd-deploy.sh
├── requirements.txt
└── CI-CD.md
```

## 🚀 Quick Start

### 1. Setup ArgoCD

```bash
# Make script executable
chmod +x microservices/scripts/setup-argocd.sh

# Install ArgoCD on EKS cluster
./microservices/scripts/setup-argocd.sh aws-project-eks-dev eu-west-1
```

### 2. Deploy with Helm

```bash
# Make script executable
chmod +x microservices/scripts/helm-deploy.sh

# Deploy microservices
./microservices/scripts/helm-deploy.sh dev latest
```

### 3. Deploy with Ansible

```bash
# Install requirements
pip install -r microservices/requirements.txt

# Make script executable
chmod +x microservices/scripts/ansible-deploy.sh

# Deploy with Ansible
./microservices/scripts/ansible-deploy.sh dev latest
```

### 4. Deploy with ArgoCD

```bash
# Make script executable
chmod +x microservices/scripts/argocd-deploy.sh

# Deploy with ArgoCD
./microservices/scripts/argocd-deploy.sh dev latest
```

## 📋 Helm Charts

### Chart Structure

```
microservices-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
└── templates/              # Kubernetes templates
    ├── namespace.yaml      # Namespace resource
    ├── mysql.yaml          # MySQL deployment
    ├── api-gateway.yaml    # API Gateway service
    ├── user-service.yaml   # User service
    ├── product-service.yaml# Product service
    ├── order-service.yaml  # Order service
    └── network-policy.yaml # Network policies
```

### Key Features

- **Templated Resources:** All Kubernetes manifests as Helm templates
- **Flexible Configuration:** Override values for different environments
- **Health Checks:** Liveness and readiness probes
- **Auto-scaling:** HPA (Horizontal Pod Autoscaler) configured
- **Network Policies:** Pod-to-pod communication security
- **Database Management:** MySQL with persistent storage

### Install Helm Chart

```bash
# Install with default values
helm install microservices microservices/helm/microservices-chart \
  -n microservices --create-namespace

# Install with custom values
helm install microservices microservices/helm/microservices-chart \
  -n microservices \
  -f microservices/helm/microservices-chart/values-dev.yaml

# Upgrade release
helm upgrade microservices microservices/helm/microservices-chart \
  -n microservices

# Rollback to previous release
helm rollback microservices -n microservices
```

## 🔄 ArgoCD Setup

### Installation

```bash
# Add ArgoCD Helm repository
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD
helm install argocd argocd/argo-cd \
  -n argocd --create-namespace

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

### ArgoCD Applications

```bash
# Apply ArgoCD applications
kubectl apply -f microservices/argocd/applications.yaml

# Get application status
argocd app get microservices-dev

# Sync application
argocd app sync microservices-dev

# View sync progress
argocd app logs microservices-dev --follow
```

### GitOps Workflow

1. **Push Code:** Commit changes to Git
2. **ArgoCD Watches:** Monitors repository for changes
3. **Auto-Sync:** Automatically syncs to target state
4. **Rollback:** Easy rollback to previous Git commit

## 🤖 Ansible Automation

### Setup Inventory

The `inventory.yaml` defines:
- Localhost connection for local execution
- EKS cluster configuration
- ArgoCD server details
- Microservices configuration

### Playbooks

#### 1. Setup ArgoCD
```bash
ansible-playbook \
  -i microservices/ansible/inventory.yaml \
  microservices/ansible/setup-argocd.yaml
```

#### 2. Deploy Microservices
```bash
ansible-playbook \
  -i microservices/ansible/inventory.yaml \
  microservices/ansible/deploy-microservices.yaml \
  -e "deploy_env=dev" \
  -e "image_tag=latest"
```

#### 3. Verify Deployment
```bash
ansible-playbook \
  -i microservices/ansible/inventory.yaml \
  microservices/ansible/verify-deployment.yaml
```

### Features

- **Kubernetes Integration:** Manages Kubernetes resources
- **Helm Support:** Deploys Helm charts
- **Error Handling:** Comprehensive error checking
- **Idempotent:** Safe to run multiple times
- **Reporting:** Generates deployment reports

## 📊 GitHub Actions CI/CD Pipeline

### Workflow Stages

1. **Build & Test** (Parallel)
   - Checkout code
   - Install dependencies
   - Run tests
   - Build Docker images
   - Security scanning

2. **Push to ECR**
   - Authenticate with AWS
   - Push images to ECR
   - Tag with git SHA and latest

3. **Validate Helm Charts**
   - Lint Helm charts
   - Validate templates
   - Check configuration

4. **Deploy to Dev**
   - Deploy to development environment
   - Wait for rollout
   - Verify deployment

5. **Integration Tests**
   - Test API endpoints
   - Verify connectivity
   - Validate functionality

6. **Deploy to Prod** (Manual Approval)
   - Requires manual approval
   - Deploys to production
   - Separate namespace

7. **Notifications**
   - Slack notifications
   - Status reports

### Workflow Triggers

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

### Required GitHub Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
GITHUB_TOKEN
ARGOCD_TOKEN
SLACK_WEBHOOK_URL
```

## 🔧 Configuration Management

### Helm Values

Override default values for different environments:

```yaml
# values-dev.yaml
global:
  environment: dev
apiGateway:
  replicaCount: 2

# values-prod.yaml
global:
  environment: prod
apiGateway:
  replicaCount: 3
```

### Kustomize Overlays

Environment-specific configurations:

```bash
# Apply dev overlay
kubectl apply -k microservices/kustomize/overlays/dev

# Apply prod overlay
kubectl apply -k microservices/kustomize/overlays/prod
```

### Ansible Variables

Pass variables at runtime:

```bash
ansible-playbook playbook.yaml \
  -e "environment=prod" \
  -e "image_tag=v1.0.0"
```

## 📈 Monitoring & Observability

### ArgoCD Dashboard
- Application sync status
- Resource health
- Deployment history
- Comparison with target state

### Kubernetes Metrics

```bash
# Pod metrics
kubectl top pods -n microservices

# Node metrics
kubectl top nodes

# Resource usage
kubectl describe node <node-name>
```

### Logs

```bash
# ArgoCD logs
kubectl logs -f deployment/argocd-server -n argocd

# Application logs
kubectl logs -f deployment/api-gateway -n microservices

# Follow multiple pods
kubectl logs -f -l app=api-gateway -n microservices
```

## 🔐 Security Best Practices

1. **RBAC:** Restrict access with Kubernetes RBAC
2. **Network Policies:** Segment pod-to-pod communication
3. **Secrets Management:** Use Kubernetes secrets for sensitive data
4. **Container Scanning:** Scan images for vulnerabilities
5. **Image Registry:** Use private ECR with authentication
6. **Pod Security:** Implement pod security standards
7. **Audit Logging:** Enable Kubernetes audit logs

## 🐛 Troubleshooting

### Deployment Stuck

```bash
# Check pod status
kubectl describe pod <pod-name> -n microservices

# Check events
kubectl get events -n microservices --sort-by='.lastTimestamp'

# View pod logs
kubectl logs <pod-name> -n microservices
```

### ArgoCD Sync Issues

```bash
# Check application status
argocd app get microservices-dev

# View sync logs
argocd app logs microservices-dev

# Manual sync
argocd app sync microservices-dev --force
```

### Helm Chart Errors

```bash
# Dry-run template rendering
helm template microservices microservices/helm/microservices-chart

# Validate chart syntax
helm lint microservices/helm/microservices-chart

# Debug values
helm get values microservices -n microservices
```

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🎯 Next Steps

1. **Setup CI/CD Pipeline**
   - Configure GitHub secrets
   - Push code to repository
   - Monitor first deployment

2. **Configure ArgoCD**
   - Add Git repositories
   - Create applications
   - Enable auto-sync

3. **Implement Monitoring**
   - Setup Prometheus
   - Configure Grafana
   - Enable CloudWatch logs

4. **Security Hardening**
   - Implement RBAC policies
   - Configure network policies
   - Enable pod security standards

5. **Scale & Optimize**
   - Configure auto-scaling
   - Optimize resource requests
   - Implement cost monitoring
