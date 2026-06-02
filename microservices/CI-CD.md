# CI/CD Documentation

## Overview

This CI/CD pipeline automates the deployment of microservices to AWS EKS using:
- **GitHub Actions** for CI/CD orchestration
- **Helm** for Kubernetes package management
- **ArgoCD** for GitOps-based deployment
- **Ansible** for alternative automation and orchestration

## Pipeline Stages

### 1. Build & Test
- Builds Docker images for each microservice
- Runs unit tests (if available)
- Performs security scanning with Trivy
- Validates Docker images

### 2. Push to ECR
- Authenticates with AWS ECR
- Pushes Docker images with Git SHA and latest tags
- Tags images for version tracking

### 3. Validate Helm Charts
- Lints Helm charts for syntax errors
- Validates Helm templates
- Ensures configuration files are correct

### 4. Deploy to Dev (ArgoCD)
- Triggers ArgoCD application sync
- Deploys microservices to dev environment
- Waits for rollout completion
- Verifies deployment status

### 5. Deploy with Ansible (Alternative)
- Installs required Python dependencies
- Executes Ansible playbooks
- Deploys Helm charts programmatically
- Verifies deployment health

### 6. Integration Tests
- Tests API endpoints
- Verifies service connectivity
- Validates application functionality

### 7. Deploy to Prod (Manual Approval)
- Requires manual approval
- Deploys to production environment
- Uses separate production namespace

### 8. Notifications
- Sends Slack notifications
- Reports pipeline status

## Deployment Methods

### Method 1: ArgoCD (Recommended)
GitOps approach with automatic synchronization:
```bash
# Prerequisites: ArgoCD installed and configured

# Create ArgoCD applications
kubectl apply -f microservices/argocd/applications.yaml

# Monitor deployment
argocd app get microservices-dev
```

### Method 2: Ansible
Imperative approach with Ansible playbooks:
```bash
# Install dependencies
pip install -r microservices/ansible/requirements.txt
ansible-galaxy collection install -r microservices/ansible/requirements.yaml

# Run deployment playbook
ansible-playbook \
  -i microservices/ansible/inventory.yaml \
  microservices/ansible/deploy-microservices.yaml \
  -e "deploy_env=dev"

# Verify deployment
ansible-playbook \
  -i microservices/ansible/inventory.yaml \
  microservices/ansible/verify-deployment.yaml
```

### Method 3: Helm Direct
Manual Helm deployment:
```bash
helm install microservices \
  microservices/helm/microservices-chart \
  -n microservices \
  --create-namespace \
  -f microservices/helm/microservices-chart/values-dev.yaml
```

### Method 4: Kustomize
Overlay-based configuration:
```bash
# Dev environment
kubectl apply -k microservices/kustomize/overlays/dev

# Prod environment
kubectl apply -k microservices/kustomize/overlays/prod
```

## Environment Setup

### GitHub Secrets Required
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
GITHUB_TOKEN
ARGOCD_TOKEN
SLACK_WEBHOOK_URL
```

### AWS Resources
- EKS cluster: aws-project-eks-dev (dev)
- EKS cluster: aws-project-eks-prod (prod)
- ECR repositories (auto-created or pre-existing)
- IAM roles with appropriate permissions

## Monitoring Deployment

### With ArgoCD
```bash
# Get application status
argocd app get microservices-dev

# Sync application
argocd app sync microservices-dev

# View application diff
argocd app diff microservices-dev
```

### With Kubernetes
```bash
# Watch deployments
kubectl get deployments -n microservices -w

# Check pod status
kubectl get pods -n microservices -o wide

# View logs
kubectl logs -f deployment/api-gateway -n microservices

# Get events
kubectl get events -n microservices
```

### With Helm
```bash
# Get release status
helm status microservices -n microservices

# Get release history
helm history microservices -n microservices

# Rollback to previous release
helm rollback microservices -n microservices
```

## Configuration

### Helm Values Overrides

Create environment-specific values files:

**values-dev.yaml:**
```yaml
global:
  environment: dev
apiGateway:
  replicaCount: 2
```

**values-prod.yaml:**
```yaml
global:
  environment: prod
apiGateway:
  replicaCount: 3
```

### Ansible Variables

Create inventory-specific variables:

```yaml
- name: deploy-dev
  vars:
    environment: dev
    image_tag: latest
    replicas: 2
```

## Troubleshooting

### Deployment Stuck

```bash
# Check pod status
kubectl describe pod <pod-name> -n microservices

# Check pod logs
kubectl logs <pod-name> -n microservices

# Check events
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Image Pull Errors

```bash
# Verify ECR credentials
kubectl get secret regcred -n microservices

# Re-create secret if needed
kubectl create secret docker-registry regcred \
  --docker-server=<account>.dkr.ecr.<region>.amazonaws.com \
  --docker-username=AWS \
  --docker-password=<password> \
  -n microservices
```

### ArgoCD Sync Issues

```bash
# Check application status
argocd app get microservices-dev

# View sync logs
argocd app logs microservices-dev

# Force sync
argocd app sync microservices-dev --force
```

## Rollback

### Helm Rollback
```bash
# List releases
helm history microservices -n microservices

# Rollback to previous release
helm rollback microservices 1 -n microservices
```

### ArgoCD Rollback
```bash
# Sync to specific revision
argocd app sync microservices-dev --revision <commit-sha>
```

### Kubernetes Rollback
```bash
# Rollout previous revision
kubectl rollout undo deployment/api-gateway -n microservices
```

## Best Practices

1. **Use ArgoCD for GitOps**: Leverage git as source of truth
2. **Tag Images Properly**: Use git commit SHA and semantic versioning
3. **Test Before Production**: Always test in dev environment first
4. **Monitor Deployments**: Use CloudWatch, Prometheus, or similar
5. **Implement RBAC**: Restrict access with Kubernetes RBAC
6. **Use Network Policies**: Implement network segmentation
7. **Regular Backups**: Backup persistent data regularly
8. **Update Dependencies**: Keep tools and dependencies updated

## Advanced Topics

### Blue-Green Deployment
Implement via Helm with separate releases:
```bash
# Deploy blue version
helm install microservices-blue ./chart -n microservices

# Deploy green version
helm install microservices-green ./chart -n microservices

# Switch traffic
kubectl patch service api-gateway -n microservices \
  -p '{"spec":{"selector":{"version":"green"}}}'
```

### Canary Deployment
Use Flagger for canary deployments:
```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: api-gateway
spec:
  targetRef:
    name: api-gateway
  service:
    port: 80
  analysis:
    interval: 1m
    maxWeight: 50
    stepWeight: 10
```

### Multi-Region Deployment
Use ArgoCD ApplicationSet:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          region: eu
```

## Related Documentation

- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
