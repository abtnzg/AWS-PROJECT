# Deployment Scripts Guide

Quick-start scripts for deploying microservices using Helm, Ansible, and ArgoCD.

## 📋 Available Scripts

### 1. setup-argocd.sh

Install and configure ArgoCD on your EKS cluster.

**Usage:**
```bash
./scripts/setup-argocd.sh <cluster-name> <region>
```

**Parameters:**
- `cluster-name` - EKS cluster name (default: aws-project-eks-dev)
- `region` - AWS region (default: eu-west-1)

**Example:**
```bash
chmod +x scripts/setup-argocd.sh
./scripts/setup-argocd.sh aws-project-eks-dev eu-west-1
```

**What it does:**
- Updates kubeconfig
- Creates argocd namespace
- Installs ArgoCD via Helm
- Waits for deployment
- Retrieves admin credentials

**Output:**
```
========================================
ArgoCD Installation Complete!
========================================

ArgoCD URL: https://a1b2c3d4-1234567890.eu-west-1.elb.amazonaws.com
Admin Username: admin
Admin Password: <password>

First login steps:
1. argocd login <URL>
2. argocd account update-password --new-password <new-password>
```

**Next steps after installation:**
```bash
# Login to ArgoCD
argocd login <URL>

# Add GitHub repository
argocd repo add https://github.com/abtnzg/AWS-PROJECT \
  --username <github-username> \
  --password <github-token>

# Create applications
argocd app create microservices-dev \
  --repo https://github.com/abtnzg/AWS-PROJECT \
  --path microservices/helm/microservices-chart \
  --dest-server https://kubernetes.default.svc
```

---

### 2. helm-deploy.sh

Deploy microservices directly using Helm.

**Usage:**
```bash
./scripts/helm-deploy.sh <environment> <image-tag>
```

**Parameters:**
- `environment` - Environment name (dev/prod, default: dev)
- `image-tag` - Docker image tag (default: latest)

**Example:**
```bash
chmod +x scripts/helm-deploy.sh
./scripts/helm-deploy.sh dev latest
./scripts/helm-deploy.sh prod v1.0.0
```

**What it does:**
- Creates namespace
- Creates temporary values file
- Installs/upgrades Helm chart
- Waits for deployments
- Displays deployment status

**Output:**
```
Deploying Microservices with Helm
Environment: dev
Image Tag: latest
Namespace: microservices

Installing/Upgrading Helm chart...
release "microservices" upgraded in 5s

Waiting for deployments to be ready...
deployment.apps/api-gateway condition met

Deployment Status
NAME                  READY   STATUS    RESTARTS   AGE
api-gateway-d8f5d     1/1     Running   0          23s
user-service-7d9cb    1/1     Running   0          20s
product-service-4k3j  1/1     Running   0          18s
order-service-5m2k9   1/1     Running   0          16s
mysql-0               1/1     Running   0          25s

NAME                  TYPE         CLUSTER-IP   EXTERNAL-IP
api-gateway           LoadBalancer 10.100.1.5   ab12cd34-5678.eu-west-1.elb.amazonaws.com
user-service          ClusterIP    10.100.1.10  <none>
product-service       ClusterIP    10.100.1.11  <none>
order-service         ClusterIP    10.100.1.12  <none>
mysql                 ClusterIP    10.100.1.13  <none>

API Gateway: http://ab12cd34-5678.eu-west-1.elb.amazonaws.com

Test the API:
  curl http://ab12cd34-5678.eu-west-1.elb.amazonaws.com/health
```

**Helm commands:**
```bash
# Check release status
helm status microservices -n microservices

# Get release values
helm get values microservices -n microservices

# View release history
helm history microservices -n microservices

# Rollback to previous version
helm rollback microservices -n microservices

# Uninstall release
helm uninstall microservices -n microservices
```

---

### 3. ansible-deploy.sh

Deploy microservices using Ansible playbooks.

**Usage:**
```bash
./scripts/ansible-deploy.sh <environment> <image-tag>
```

**Parameters:**
- `environment` - Environment name (dev/prod, default: dev)
- `image-tag` - Docker image tag (default: latest)

**Example:**
```bash
chmod +x scripts/ansible-deploy.sh
./scripts/ansible-deploy.sh dev latest
./scripts/ansible-deploy.sh prod v1.0.0
```

**Prerequisites:**
```bash
# Install Python requirements
pip install -r microservices/requirements.txt

# Install Ansible collections
ansible-galaxy collection install -r microservices/ansible/requirements.yaml
```

**What it does:**
- Installs Ansible requirements
- Validates playbook syntax
- Runs deployment playbook
- Verifies deployment
- Generates deployment report

**Output:**
```
Deploying Microservices with Ansible
Environment: dev
Image Tag: latest

Installing Ansible collections...
Starting galaxy install process
Installing 'kubernetes.core:2.4.0'
Installing 'amazon.aws:5.4.0'

Running deployment playbook...
PLAY [Deploy Microservices] **
TASK [Deploy Helm chart] **
ok: [localhost]

Verifying deployment...
TASK [Check pod status] **
ok: [localhost] => {
  "pods": ["api-gateway-d8f5d", "user-service-7d9cb", ...]
}

Deployment completed with Ansible!
```

**Ansible commands:**
```bash
# List inventory
ansible-inventory -i ansible/inventory.yaml --list

# Run specific task
ansible-playbook -i ansible/inventory.yaml ansible/deploy-microservices.yaml --tags "helm"

# Debug output
ansible-playbook -i ansible/inventory.yaml ansible/deploy-microservices.yaml -vvv

# Dry-run (check mode)
ansible-playbook -i ansible/inventory.yaml ansible/deploy-microservices.yaml --check
```

---

### 4. argocd-deploy.sh

Deploy microservices using ArgoCD.

**Usage:**
```bash
./scripts/argocd-deploy.sh <environment> <image-tag>
```

**Parameters:**
- `environment` - Environment name (dev/prod, default: dev)
- `image-tag` - Docker image tag (default: latest)

**Example:**
```bash
chmod +x scripts/argocd-deploy.sh
./scripts/argocd-deploy.sh dev latest
./scripts/argocd-deploy.sh prod v1.0.0
```

**Prerequisites:**
```bash
# ArgoCD server should be running
kubectl get deployment argocd-server -n argocd

# Set ArgoCD token environment variable
export ARGOCD_TOKEN=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d)
```

**What it does:**
- Applies ArgoCD applications
- Syncs application
- Waits for sync completion
- Displays application status

**Output:**
```
Deploying Microservices with ArgoCD
Environment: dev
Image Tag: latest
Application: microservices-dev

ArgoCD Server: argocd-server-123456789.eu-west-1.elb.amazonaws.com

Applying ArgoCD applications...
application.argoproj.io/microservices-dev created

Syncing ArgoCD application: microservices-dev...
application.argoproj.io/microservices-dev synced

Waiting for application to sync...
Application Status

NAME             NAMESPACE      CLUSTER                        STATE    SYNC STATUS   HEALTH STATUS
microservices-dev microservices https://kubernetes.default.svc Synced   OutOfSync     Healthy
```

**ArgoCD commands:**
```bash
# Login to ArgoCD
argocd login <server> --auth-token $ARGOCD_TOKEN

# Get application status
argocd app get microservices-dev

# Sync application
argocd app sync microservices-dev

# Wait for sync
argocd app wait microservices-dev --sync

# View logs
argocd app logs microservices-dev --follow

# Get application details
argocd app get microservices-dev --refresh

# Compare with target state
argocd app diff microservices-dev
```

---

## 🔄 Deployment Workflow

### Quick Start (Recommended)

```bash
# 1. Setup ArgoCD
chmod +x scripts/setup-argocd.sh
./scripts/setup-argocd.sh aws-project-eks-dev eu-west-1

# 2. Deploy with Helm
chmod +x scripts/helm-deploy.sh
./scripts/helm-deploy.sh dev latest

# 3. Configure GitHub secrets and push code
# 4. GitHub Actions automatically handles further deployments
```

### Step-by-Step Deployment

```bash
# 1. Install dependencies
pip install -r microservices/requirements.txt

# 2. Setup ArgoCD
./scripts/setup-argocd.sh aws-project-eks-dev eu-west-1

# 3. Deploy to Dev
./scripts/helm-deploy.sh dev latest

# 4. Verify deployment
kubectl get pods -n microservices -o wide
kubectl get svc -n microservices

# 5. Run integration tests
kubectl port-forward svc/api-gateway 3000:3000 -n microservices
curl http://localhost:3000/health

# 6. Deploy to Prod
./scripts/helm-deploy.sh prod latest
```

### Using Ansible Alternative

```bash
# 1. Install Ansible requirements
pip install -r microservices/requirements.txt

# 2. Setup ArgoCD with Ansible
ansible-playbook -i microservices/ansible/inventory.yaml \
  microservices/ansible/setup-argocd.yaml

# 3. Deploy with Ansible
./scripts/ansible-deploy.sh dev latest

# 4. Verify deployment
./scripts/ansible-deploy.sh dev latest
```

### Using GitHub Actions (Automatic)

```bash
# 1. Configure GitHub secrets
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - GITHUB_TOKEN
# - ARGOCD_TOKEN
# - SLACK_WEBHOOK_URL (optional)

# 2. Push code to main branch
git push origin main

# 3. GitHub Actions automatically:
# - Builds Docker images
# - Runs tests
# - Pushes to ECR
# - Deploys to dev
# - Runs integration tests
# - Waits for manual approval for prod

# 4. Approve production deployment in GitHub UI
```

---

## 🔐 Environment Variables

Set these before running scripts:

```bash
export AWS_REGION=eu-west-1
export AWS_ACCOUNT_ID=205474062795
export CLUSTER_NAME=aws-project-eks-dev
export ECR_REGISTRY=205474062795.dkr.ecr.eu-west-1.amazonaws.com
export IMAGE_TAG=latest
export ENVIRONMENT=dev
```

---

## 📝 Script Best Practices

1. **Always check cluster connectivity first**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

2. **Verify namespaces exist**
   ```bash
   kubectl get namespaces
   ```

3. **Check image availability in ECR**
   ```bash
   aws ecr describe-images --repository-name api-gateway \
     --region eu-west-1
   ```

4. **Validate Helm charts before deployment**
   ```bash
   helm lint microservices/helm/microservices-chart
   helm template microservices microservices/helm/microservices-chart
   ```

5. **Always perform dry-runs first**
   ```bash
   ./scripts/helm-deploy.sh dev latest --dry-run
   ```

---

## 🐛 Common Issues

### Permission Denied
```bash
chmod +x scripts/*.sh
```

### Namespace Not Found
```bash
kubectl create namespace microservices
```

### Image Not Found in ECR
```bash
# Build and push image first
docker build -t api-gateway:latest services/api-gateway/
docker tag api-gateway:latest \
  205474062795.dkr.ecr.eu-west-1.amazonaws.com/api-gateway:latest
docker push 205474062795.dkr.ecr.eu-west-1.amazonaws.com/api-gateway:latest
```

### ArgoCD Server Not Accessible
```bash
# Port forward to access UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Access at https://localhost:8080
```

### Helm Chart Validation Fails
```bash
# Check chart syntax
helm lint microservices/helm/microservices-chart

# View rendered templates
helm template microservices microservices/helm/microservices-chart

# Debug values
helm get values microservices -n microservices
```

---

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

---

**Happy Deploying! 🚀**
