# Complete Project Integration Guide

Final step-by-step guide to integrate Terraform infrastructure with microservices CI/CD architecture.

## 🎯 Integration Overview

Your AWS project now includes:

```
AWS-PROJECT/
├── Terraform-infrastr/           # Infrastructure as Code
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── bootstrap/                # Initial AWS setup
│   └── modules/                  # Reusable infrastructure
│       ├── vpc/
│       ├── eks/
│       ├── ecr/
│       ├── alb/
│       ├── acm/
│       ├── api_gateway/
│       ├── external_dns/
│       └── sg/
├── microservices/                # Application Code
│   ├── services/                 # 4 microservices
│   │   ├── api-gateway/
│   │   ├── user-service/
│   │   ├── product-service/
│   │   └── order-service/
│   ├── helm/                     # Kubernetes packaging
│   │   └── microservices-chart/
│   ├── argocd/                   # GitOps deployment
│   ├── ansible/                  # Infrastructure automation
│   ├── kustomize/                # Configuration management
│   └── scripts/                  # Deployment automation
└── .github/workflows/            # CI/CD Automation
    └── microservices-cicd.yml    # Complete pipeline
```

## 📋 Architecture Flow

```
┌────────────────────────────────────────────────────────────┐
│                     AWS Account                             │
│                  (205474062795)                             │
│              (eu-west-1 region)                             │
└────────────────┬─────────────────────────────────────────┬──┘
                 │                                          │
        ┌────────▼───────────┐                   ┌─────────▼──────┐
        │  Terraform         │                   │ GitHub Actions │
        │  Infrastructure    │                   │   CI/CD         │
        │ - VPC              │                   │ - Build         │
        │ - EKS              │                   │ - Test          │
        │ - RDS              │                   │ - Deploy        │
        │ - ALB              │                   └────────┬────────┘
        │ - ECR              │                           │
        └────────┬───────────┘                           ▼
                 │                            ┌──────────────────┐
                 │                            │  ECR Registry    │
                 ▼                            │  (Docker Images) │
        ┌────────────────────┐                └────────┬─────────┘
        │  EKS Cluster       │                        │
        │ (Kubernetes)       │◄───────────────────────┘
        │                    │
        │ Namespaces:        │
        │ - microservices    │
        │ - argocd           │
        │ - kube-system      │
        └────────┬───────────┘
                 │
        ┌────────┴────────┬───────────┬─────────────┐
        ▼                 ▼           ▼             ▼
    ┌─────────┐   ┌──────────┐  ┌──────────┐  ┌────────┐
    │ ArgoCD  │   │ Services │  │   Helm   │  │ MySQL  │
    │ (GitOps)│   │ (4 apps) │  │ Release  │  │(State) │
    └─────────┘   └──────────┘  └──────────┘  └────────┘
        │
        └──────▶ Git Repository (Sync Source)
```

## 🚀 Deployment Workflow

### Phase 1: Infrastructure Setup (Terraform)

```bash
# 1. Initialize Terraform
cd Terraform-infrastr
terraform init

# 2. Review changes
terraform plan

# 3. Deploy infrastructure
terraform apply

# Output includes:
# - VPC ID
# - EKS cluster name
# - ECR registry
# - ALB endpoint
```

### Phase 2: Configure CI/CD (GitHub)

```bash
# 1. Configure GitHub secrets
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - GITHUB_TOKEN
# - ARGOCD_TOKEN (generated in next phase)
# - SLACK_WEBHOOK_URL (optional)

# 2. Verify secrets
# Go to: Repository > Settings > Secrets
# Confirm all required secrets exist
```

### Phase 3: Setup Kubernetes (Helm + ArgoCD)

```bash
# 1. Update kubeconfig
aws eks update-kubeconfig \
  --name aws-project-eks-dev \
  --region eu-west-1

# 2. Setup ArgoCD
cd microservices/scripts
chmod +x setup-argocd.sh
./setup-argocd.sh aws-project-eks-dev eu-west-1

# Output includes:
# - ArgoCD URL
# - Admin credentials
# - Token generation command

# 3. Get ArgoCD token
ARGOCD_URL=<from-previous-step>
argocd login $ARGOCD_URL
argocd account generate-token > argocd-token.txt

# 4. Add GitHub token to GitHub secrets
# - ARGOCD_TOKEN: (from previous step)
```

### Phase 4: Deploy Microservices

**Option A: Direct Helm Deployment**
```bash
./helm-deploy.sh dev latest
./helm-deploy.sh prod latest
```

**Option B: Ansible Deployment**
```bash
pip install -r ../requirements.txt
./ansible-deploy.sh dev latest
./ansible-deploy.sh prod latest
```

**Option C: ArgoCD Deployment (Recommended)**
```bash
./argocd-deploy.sh dev latest
./argocd-deploy.sh prod latest
```

**Option D: GitHub Actions (Automatic)**
```bash
# Push to repository
git push origin main

# GitHub Actions automatically:
# 1. Builds images
# 2. Deploys to dev
# 3. Runs tests
# 4. Waits for prod approval
```

### Phase 5: Verify Deployment

```bash
# Check cluster
kubectl cluster-info
kubectl get nodes

# Check namespaces
kubectl get namespaces

# Check microservices
kubectl get pods -n microservices
kubectl get svc -n microservices

# Test API
API_ENDPOINT=$(kubectl get svc api-gateway -n microservices \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$API_ENDPOINT/health

# Check ArgoCD
kubectl get pods -n argocd
argocd app list
argocd app get microservices-dev
```

---

## 📦 Components Summary

### Terraform Infrastructure

**Modules:**
- `vpc` - Virtual Private Cloud with public/private subnets
- `eks` - Kubernetes cluster with managed node groups
- `ecr` - Docker image registry
- `alb` - Application load balancer
- `acm` - SSL/TLS certificates
- `api_gateway` - REST API gateway (optional)
- `external_dns` - Route53 integration
- `sg` - Security groups and NACL

**Features:**
- Multi-AZ deployment
- Auto-scaling groups
- VPC peering
- Encrypted volumes
- Managed database (optional)

### Microservices Application

**Services (4 total):**
1. **API Gateway** (Port 3000)
   - Entry point
   - Request routing
   - Rate limiting

2. **User Service** (Port 3001)
   - User management
   - CRUD operations
   - MySQL backend

3. **Product Service** (Port 3002)
   - Product catalog
   - Inventory management
   - MySQL backend

4. **Order Service** (Port 3003)
   - Order processing
   - Status tracking
   - MySQL backend

**Data:** MySQL 8.0 database

### Kubernetes Deployment

**Helm Chart** (`microservices-chart/`):
- 10 template files
- 5 ConfigMaps
- 3 Services
- 4 Deployments
- HPA (Horizontal Pod Autoscaler)
- Network Policies
- PersistentVolumes

**ArgoCD Applications:**
- Development: auto-sync enabled
- Production: manual sync
- ApplicationSet for environment generation

### CI/CD Pipeline

**GitHub Actions Workflow** (`microservices-cicd.yml`):
- **Build & Test:** Docker image creation, test suite
- **Push to ECR:** Image registry upload
- **Validate Helm:** Chart validation
- **Deploy Dev:** Automatic deployment
- **Integration Tests:** API testing
- **Deploy Prod:** Manual approval required
- **Notifications:** Slack messages

**Deployment Options:**
1. Helm (direct)
2. ArgoCD (GitOps) - Recommended
3. Ansible (orchestration)
4. GitHub Actions (automated)

---

## ✅ Implementation Checklist

### Pre-Deployment Verification

- [ ] AWS Account configured
- [ ] Terraform initialized
- [ ] AWS credentials configured locally
- [ ] GitHub repository setup
- [ ] Git repository cloned locally

### Infrastructure (Terraform)

- [ ] Review terraform plan
- [ ] Deploy VPC, EKS, ECR, ALB
- [ ] Verify resources in AWS Console
- [ ] Update kubeconfig: `aws eks update-kubeconfig ...`
- [ ] Test cluster access: `kubectl cluster-info`

### Kubernetes Setup

- [ ] Create microservices namespace: `kubectl create namespace microservices`
- [ ] Create argocd namespace: `kubectl create namespace argocd`
- [ ] Install ArgoCD: `./scripts/setup-argocd.sh`
- [ ] Get ArgoCD admin password
- [ ] Generate ArgoCD token

### GitHub Configuration

- [ ] Add AWS_ACCESS_KEY_ID secret
- [ ] Add AWS_SECRET_ACCESS_KEY secret
- [ ] Add GITHUB_TOKEN secret
- [ ] Add ARGOCD_TOKEN secret
- [ ] Add SLACK_WEBHOOK_URL secret (optional)
- [ ] Verify workflow file: `.github/workflows/microservices-cicd.yml`

### CI/CD Testing

- [ ] Push test branch to GitHub
- [ ] Monitor GitHub Actions
- [ ] Verify build and test stage
- [ ] Confirm image pushed to ECR
- [ ] Check deployment to dev cluster
- [ ] Run integration tests
- [ ] Approve prod deployment (if needed)

### Monitoring & Validation

- [ ] Verify pods running: `kubectl get pods -n microservices`
- [ ] Check services: `kubectl get svc -n microservices`
- [ ] Test API endpoint: `curl http://<api-gateway>/health`
- [ ] Check ArgoCD sync status
- [ ] Review pod logs: `kubectl logs <pod>`
- [ ] Monitor metrics and alerts

---

## 🔧 Configuration Reference

### AWS Resources

```
Account ID: 205474062795
Region: eu-west-1
Domain: 205474062795.realhandsonlabs.net

EKS Cluster: aws-project-eks-dev
ECR Repositories:
  - api-gateway
  - user-service
  - product-service
  - order-service

Load Balancer: Application Load Balancer (ALB)
Certificate: AWS Certificate Manager (ACM)
DNS: Route 53
```

### Kubernetes Configuration

```
Cluster: AWS EKS
Version: 1.27+
CNI: AWS VPC CNI
Namespaces:
  - microservices (applications)
  - argocd (GitOps)
  - kube-system (system)

StorageClass: gp2 (default)
IngressClass: alb (AWS Load Balancer)
```

### GitHub Configuration

```
Repository: aws-project-eks
Branch Protection:
  - Require pull request reviews
  - Require status checks
  - Dismiss stale approvals

Environments:
  - development (auto-deploy)
  - production (manual approval)
```

---

## 🐛 Troubleshooting Guide

### Terraform Issues

```bash
# Validate configuration
terraform validate

# Check state
terraform state list
terraform state show resource_name

# Plan changes
terraform plan

# Debug with verbose output
TF_LOG=DEBUG terraform apply
```

### Kubernetes Issues

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get events

# Check namespace
kubectl get ns
kubectl describe ns microservices

# Check pod status
kubectl get pods -n microservices -o wide
kubectl describe pod pod_name -n microservices
kubectl logs pod_name -n microservices
```

### ArgoCD Issues

```bash
# Check ArgoCD status
kubectl get pods -n argocd
kubectl logs deployment/argocd-server -n argocd

# ArgoCD CLI commands
argocd app list
argocd app get microservices-dev
argocd app logs microservices-dev
```

### GitHub Actions Issues

```bash
# View workflow runs
# Go to: Repository > Actions

# Check logs for each job
# Click on workflow run > Click on job

# Debug locally
act -l  # list workflows
act -j build-and-test  # run locally
```

---

## 📚 Documentation Files

- [Terraform Infrastructure](../Terraform-infrastr/README.md)
- [Microservices Architecture](README.md)
- [Helm, ArgoCD, Ansible Guide](HELM-ARGOCD-ANSIBLE.md)
- [CI/CD Complete Guide](CI-CD.md)
- [Deployment Scripts](scripts/README.md)
- [GitHub Setup Guide](GITHUB-SETUP.md)
- [Infrastructure Integration](INFRASTRUCTURE-INTEGRATION.md)

---

## 🎯 Next Steps

1. **Immediate (Week 1)**
   - [x] Deploy Terraform infrastructure
   - [x] Configure GitHub secrets
   - [x] Setup ArgoCD on EKS
   - [x] Initial deployment

2. **Short-term (Week 2-3)**
   - [ ] Configure monitoring (Prometheus/Grafana)
   - [ ] Setup log aggregation (CloudWatch/ELK)
   - [ ] Implement backup strategy
   - [ ] Setup disaster recovery

3. **Medium-term (Month 2)**
   - [ ] Implement service mesh (Istio)
   - [ ] Add canary deployments
   - [ ] Setup cost optimization
   - [ ] Implement auto-scaling policies

4. **Long-term (Month 3+)**
   - [ ] Multi-region deployment
   - [ ] Advanced networking
   - [ ] Custom monitoring dashboards
   - [ ] Team runbooks and training

---

## 💡 Best Practices

1. **Infrastructure as Code**
   - Store all infrastructure in Terraform
   - Version control configuration
   - Use modules for reusability

2. **GitOps Workflow**
   - Git as single source of truth
   - Automated deployments
   - Pull request-based changes

3. **CI/CD Pipeline**
   - Automated testing
   - Security scanning
   - Multi-environment deployments
   - Manual approval for production

4. **Kubernetes Best Practices**
   - Resource requests and limits
   - Health checks
   - Auto-scaling policies
   - Network policies

5. **Security**
   - IAM least privilege
   - Secrets management
   - Network segmentation
   - Regular updates

---

## 🚀 Final Status

✅ **All components deployed and integrated:**
- Terraform infrastructure ready
- Kubernetes cluster running
- ArgoCD setup complete
- CI/CD pipeline automated
- 4 microservices deployed
- Database configured
- Load balancer active
- DNS configured
- Security implemented

**Ready for production deployment!** 🎉

---

**For detailed information, consult the specific documentation files listed above.**

For support, refer to:
- [Troubleshooting Guide](#-troubleshooting-guide)
- [Common Issues in Deployment Scripts](scripts/README.md#-common-issues)
- [GitHub Setup Guide](GITHUB-SETUP.md)
