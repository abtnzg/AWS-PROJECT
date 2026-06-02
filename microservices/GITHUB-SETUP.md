# GitHub CI/CD Configuration Guide

Complete guide to configure GitHub Actions with AWS credentials, ArgoCD, and deployment automation.

## 📋 Overview

Your GitHub Actions workflow requires configuration of several secrets and settings to automate deployments to AWS EKS.

## 🔐 Required Secrets

### 1. AWS Access Credentials

Used for ECR authentication and infrastructure access.

**Where to find:**
- AWS Console > IAM > Users > Your User
- Access Keys tab

**Steps to create:**
1. Go to AWS Console
2. Navigate to IAM > Users > Select your user
3. Click "Security credentials" tab
4. Click "Create access key"
5. Download the access key and secret key

**GitHub setup:**
1. Go to GitHub > Your Repository > Settings > Secrets
2. Click "New repository secret"
3. Add two secrets:

```
Name: AWS_ACCESS_KEY_ID
Value: AKIA...

Name: AWS_SECRET_ACCESS_KEY
Value: wJal...
```

---

### 2. GitHub Token

Used to access GitHub API and manage artifacts.

**Steps to create:**
1. Go to GitHub > Settings > Developer settings > Personal access tokens
2. Click "Generate new token"
3. Select scopes:
   - `repo` - Full control of private repositories
   - `read:packages` - Read packages
   - `write:packages` - Write packages

**GitHub setup:**
1. Go to Repository > Settings > Secrets
2. Click "New repository secret"
3. Add secret:

```
Name: GITHUB_TOKEN
Value: ghp_...
```

---

### 3. ArgoCD Token

Used to deploy applications via ArgoCD.

**Steps to get:**

After ArgoCD is installed on your cluster:

```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d

# Login to ArgoCD
argocd login <argocd-server>

# Generate API token
argocd account generate-token --account <username>
```

**GitHub setup:**
1. Go to Repository > Settings > Secrets
2. Click "New repository secret"
3. Add secret:

```
Name: ARGOCD_TOKEN
Value: eyJhbGc...
```

---

### 4. Slack Webhook (Optional)

Used for deployment notifications.

**Steps to create:**
1. Go to Slack workspace
2. Create or select a channel for notifications
3. Go to Slack App Directory > Search "Incoming Webhooks"
4. Click "Add"
5. Select channel and copy webhook URL

**GitHub setup:**
1. Go to Repository > Settings > Secrets
2. Click "New repository secret"
3. Add secret:

```
Name: SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/T...
```

---

## 🔧 GitHub Repository Settings

### Workflow Permissions

1. Go to Repository > Settings > Actions > General
2. Under "Workflow permissions":
   - Select: "Read and write permissions"
   - Check: "Allow GitHub Actions to create and approve pull requests"

### Branch Protection Rules

Recommended for production deployments:

1. Go to Repository > Settings > Branches
2. Add branch protection rule for `main`:
   - Require pull request reviews before merging
   - Require status checks to pass
   - Dismiss stale pull request approvals
   - Require branches to be up to date before merging

### Environments

For separate dev/prod deployments:

1. Go to Repository > Settings > Environments
2. Create `development` environment:
   - No approval required
3. Create `production` environment:
   - Add protection rule: "Require manual review"
   - Add reviewers who can approve deployments

---

## ✅ Configuration Checklist

### Step 1: Create AWS Credentials
- [ ] Go to AWS IAM Console
- [ ] Create IAM user or use existing
- [ ] Create access key
- [ ] Add `AWS_ACCESS_KEY_ID` secret to GitHub
- [ ] Add `AWS_SECRET_ACCESS_KEY` secret to GitHub

### Step 2: Create GitHub Token
- [ ] Go to GitHub > Settings > Developer settings > Personal access tokens
- [ ] Generate new token with `repo` and `packages` scopes
- [ ] Add `GITHUB_TOKEN` secret to GitHub

### Step 3: Setup ArgoCD
- [ ] Run: `./scripts/setup-argocd.sh`
- [ ] Get ArgoCD admin password
- [ ] Login to ArgoCD: `argocd login <server>`
- [ ] Generate ArgoCD token: `argocd account generate-token`
- [ ] Add `ARGOCD_TOKEN` secret to GitHub

### Step 4: (Optional) Setup Slack Notifications
- [ ] Go to Slack workspace
- [ ] Create incoming webhook
- [ ] Add `SLACK_WEBHOOK_URL` secret to GitHub

### Step 5: Verify Secrets
- [ ] Go to Repository > Settings > Secrets
- [ ] Confirm all required secrets are present:
  - [ ] AWS_ACCESS_KEY_ID
  - [ ] AWS_SECRET_ACCESS_KEY
  - [ ] GITHUB_TOKEN
  - [ ] ARGOCD_TOKEN
  - [ ] SLACK_WEBHOOK_URL (optional)

---

## 🚀 First Deployment

### 1. Prepare Code

```bash
# Create branch
git checkout -b feature/initial-deployment

# Make changes
# ...

# Commit changes
git add .
git commit -m "Initial microservices deployment"
```

### 2. Create Pull Request

```bash
# Push branch
git push origin feature/initial-deployment

# Create PR in GitHub UI
```

### 3. Monitor Workflow

1. Go to GitHub > Actions
2. Click on your workflow run
3. Watch the pipeline:
   - Build & Test
   - Push to ECR
   - Validate Helm
   - Deploy to Dev
   - Integration Tests

### 4. Approve Production Deployment (Optional)

1. After all tests pass, go to workflow summary
2. Click "Review deployments"
3. Select "production" environment
4. Click "Approve and deploy"

### 5. Merge to Main

```bash
# Merge PR in GitHub UI
git fetch origin
git checkout main
git pull origin main
```

---

## 🔍 Workflow Stages

### Stage 1: Build & Test

**What it does:**
- Builds Docker images for each service
- Runs test suite
- Scans images for vulnerabilities

**Secrets used:**
- `GITHUB_TOKEN`

**Failure handling:**
- Stops pipeline if tests fail
- Notifies via GitHub checks

### Stage 2: Push to ECR

**What it does:**
- Authenticates with AWS
- Pushes images to ECR
- Tags with git SHA and latest

**Secrets used:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Failure handling:**
- Stops pipeline if push fails
- Attempts retry

### Stage 3: Validate Helm

**What it does:**
- Lints Helm charts
- Validates templates
- Checks configuration

**No secrets required**

**Failure handling:**
- Stops pipeline if validation fails

### Stage 4: Deploy Dev

**What it does:**
- Deploys to development environment
- Uses ArgoCD sync
- Waits for rollout

**Secrets used:**
- `ARGOCD_TOKEN`

**Failure handling:**
- Stops pipeline if deployment fails
- Rollback to previous version

### Stage 5: Integration Tests

**What it does:**
- Tests API endpoints
- Verifies service connectivity
- Checks health endpoints

**Secrets used:**
- None

**Failure handling:**
- Fails if any test fails
- Generates report

### Stage 6: Deploy Production (Manual)

**What it does:**
- Waits for manual approval
- Deploys to production environment
- Updates load balancer

**Secrets used:**
- `ARGOCD_TOKEN`

**Requires:**
- Manual approval via GitHub UI

**Failure handling:**
- Deployment blocked without approval

### Stage 7: Notifications

**What it does:**
- Sends status to Slack
- Includes deployment summary
- Links to logs

**Secrets used:**
- `SLACK_WEBHOOK_URL`

---

## 🔗 Workflow Triggers

### Automatic Triggers

```yaml
# Trigger on push to main or develop
- push:
    branches: [main, develop]

# Trigger on pull request to main
- pull_request:
    branches: [main]
```

### Manual Trigger

```yaml
# Manual dispatch via GitHub UI
- workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'dev'
```

---

## 📊 Monitoring & Debugging

### View Workflow Logs

1. Go to GitHub Repository > Actions
2. Click on workflow run
3. Click on job to expand
4. View logs for each step

### Common Errors

#### AWS Authentication Failed
```
Error: Unable to locate credentials
```
**Solution:**
- Verify `AWS_ACCESS_KEY_ID` secret is set
- Verify `AWS_SECRET_ACCESS_KEY` secret is set
- Check secret values don't have extra spaces

#### ECR Push Failed
```
Error: image with ID <sha> not found
```
**Solution:**
- Verify Docker build succeeded
- Check ECR repository exists
- Verify AWS credentials have ECR permissions

#### Helm Template Failed
```
Error: invalid template
```
**Solution:**
- Run `helm lint microservices/helm/microservices-chart`
- Check template syntax
- Verify values file format

#### ArgoCD Sync Failed
```
error syncing application
```
**Solution:**
- Verify `ARGOCD_TOKEN` is valid
- Check ArgoCD applications exist
- Verify Git repository is accessible

---

## 🔐 Security Best Practices

1. **Use Least Privilege IAM**
   - Create dedicated IAM user for CI/CD
   - Grant minimum required permissions
   - Rotate access keys regularly

2. **Protect Secrets**
   - Never commit secrets to Git
   - Use GitHub Secrets for sensitive data
   - Rotate tokens periodically

3. **Code Review**
   - Require pull request reviews
   - Block merge without approval
   - Review infrastructure changes

4. **Audit Logging**
   - Enable GitHub audit log
   - Monitor deployments
   - Set up alerts

5. **Network Security**
   - Use VPC and security groups
   - Enable ALB security groups
   - Use TLS for communication

---

## 🧪 Testing Workflow

### Local Testing

Before pushing to GitHub:

```bash
# Install act (GitHub Actions runner)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# Run workflow locally
act -j build-and-test
```

### Dry-Run Deployment

```bash
# Validate Helm chart
helm lint microservices/helm/microservices-chart

# Template rendering
helm template microservices microservices/helm/microservices-chart

# Dry-run in Kubernetes
kubectl apply -f manifests/ --dry-run=client
```

---

## 📞 Support & Troubleshooting

### Common Issues

1. **"Secret not found"**
   - Verify secret name matches workflow
   - Check secret values are set
   - Try adding/removing leading/trailing spaces

2. **"Permission denied" (ECR)**
   - Verify IAM user has ecr:* permissions
   - Check AWS region matches
   - Verify AWS account ID is correct

3. **"Deployment timeout"**
   - Check pod logs: `kubectl logs <pod>`
   - Check resource limits
   - Verify image pull secrets

4. **"Helm release failed"**
   - Check values syntax
   - Run `helm lint`
   - Review previous release: `helm history`

### Getting Help

1. Check GitHub Actions logs
2. Review deployment script output
3. Check Kubernetes events: `kubectl get events`
4. Check pod logs: `kubectl logs <pod>`
5. Review ArgoCD dashboard

---

## ✨ Next Steps

1. ✅ Configure all secrets in GitHub
2. ✅ Setup ArgoCD on EKS
3. ✅ Make initial commit to `develop` branch
4. ✅ Monitor GitHub Actions workflow
5. ✅ Approve production deployment
6. ✅ Verify services running in production

---

**Your CI/CD pipeline is now ready!** 🎉

For detailed information, see:
- [Deployment Scripts Guide](scripts/README.md)
- [Complete CI/CD Documentation](CI-CD.md)
- [Helm, ArgoCD, Ansible Guide](HELM-ARGOCD-ANSIBLE.md)
