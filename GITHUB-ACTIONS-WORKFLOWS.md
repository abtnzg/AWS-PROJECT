# 🚀 GitHub Actions Workflows - Complete Management Guide

All deployment tasks are now managed via GitHub Actions workflows instead of shell scripts!

## 📋 Overview

Instead of running local scripts, you can manage everything directly from GitHub UI:

```
GitHub Actions Workflows (No local scripts needed!)
├── setup-argocd.yml           ← Install ArgoCD on EKS
├── helm-deploy.yml            ← Deploy with Helm
├── argocd-deploy.yml          ← Deploy with ArgoCD (GitOps)
├── ansible-deploy.yml         ← Deploy with Ansible
├── deployment-status.yml      ← Check deployment status
├── undeploy.yml               ← Remove services
└── microservices-cicd.yml     ← Full CI/CD pipeline (existing)
```

---

## 🎯 Quick Start (GitHub UI Only)

### 1️⃣ Setup ArgoCD

```
1. Go to: Repository > Actions > "Setup ArgoCD"
2. Click: "Run workflow"
3. Leave defaults or customize:
   - cluster_name: aws-project-eks-dev
   - aws_region: eu-west-1
4. Click: "Run workflow"
5. Wait for completion
6. Download artifact: argocd-setup-report
7. Get token: argocd account generate-token
8. Add ARGOCD_TOKEN to GitHub Secrets
```

### 2️⃣ Deploy with Helm

```
1. Go to: Repository > Actions > "Deploy with Helm"
2. Click: "Run workflow"
3. Fill inputs:
   - environment: dev
   - image_tag: latest
4. Click: "Run workflow"
5. Monitor progress in real-time
6. Check pod status: See workflow logs
7. Get API endpoint from logs
```

### 3️⃣ Deploy with ArgoCD (Recommended)

```
1. Go to: Repository > Actions > "Deploy with ArgoCD"
2. Click: "Run workflow"
3. Fill inputs:
   - environment: dev
   - image_tag: latest
   - force_sync: false
4. Click: "Run workflow"
5. Monitor sync progress
6. Applications auto-syncing from Git
```

### 4️⃣ Deploy with Ansible

```
1. Go to: Repository > Actions > "Deploy with Ansible"
2. Click: "Run workflow"
3. Fill inputs:
   - environment: dev
   - image_tag: latest
4. Click: "Run workflow"
5. See Ansible execution in logs
6. Deployment verification runs automatically
```

### 5️⃣ Check Deployment Status

```
1. Go to: Repository > Actions > "Deployment Status"
2. Click: "Run workflow"
3. Select environment: dev or prod
4. Click: "Run workflow"
5. View complete status report
6. Download status-report artifact
```

### 6️⃣ Undeploy Services

```
1. Go to: Repository > Actions > "Undeploy Services"
2. Click: "Run workflow"
3. Fill inputs:
   - environment: dev
   - method: helm (or argocd, kubectl)
4. Click: "Run workflow"
5. Services removed automatically
6. Download undeploy-report
```

---

## 📊 Workflow Details

### Setup ArgoCD Workflow

**Purpose:** Install ArgoCD on EKS cluster

**Inputs:**
- `cluster_name` (default: aws-project-eks-dev)
- `aws_region` (default: eu-west-1)

**What it does:**
1. ✅ Updates kubeconfig
2. ✅ Creates ArgoCD namespace
3. ✅ Adds Helm repo
4. ✅ Installs ArgoCD with Helm
5. ✅ Waits for deployment
6. ✅ Gets admin password
7. ✅ Provides setup instructions

**Output:**
- Artifact: `argocd-setup-report.txt`
- Contains: URL, credentials, next steps
- Slack notification on success

**Time:** ~5-10 minutes

---

### Helm Deploy Workflow

**Purpose:** Deploy microservices using Helm

**Inputs:**
- `environment` (dev/prod)
- `image_tag` (e.g., latest, v1.0.0)

**What it does:**
1. ✅ Updates kubeconfig
2. ✅ Creates namespace
3. ✅ Validates Helm chart
4. ✅ Creates values override
5. ✅ Installs/upgrades release
6. ✅ Waits for deployments
7. ✅ Gets API endpoint
8. ✅ Runs health check
9. ✅ Generates report

**Output:**
- Artifact: `helm-deployment-report.txt`
- Contains: Pod status, services, endpoint
- Slack notification on success/failure
- Real-time logs

**Time:** ~5-10 minutes

---

### ArgoCD Deploy Workflow

**Purpose:** Deploy using ArgoCD (GitOps)

**Inputs:**
- `environment` (dev/prod)
- `image_tag` (e.g., latest, v1.0.0)
- `force_sync` (force even if synced)

**What it does:**
1. ✅ Updates kubeconfig
2. ✅ Installs ArgoCD CLI
3. ✅ Gets ArgoCD server endpoint
4. ✅ Applies applications
5. ✅ Syncs application
6. ✅ Waits for completion
7. ✅ Verifies deployment
8. ✅ Generates report

**Output:**
- Artifact: `argocd-deployment-report.txt`
- Contains: App status, pods, endpoint
- Slack notification on success/failure
- Real-time sync logs

**Time:** ~10-15 minutes

**Benefits:**
- ✅ Git-driven deployment (source of truth)
- ✅ Automatic synchronization
- ✅ Easy rollback to previous commit
- ✅ Dashboard visibility

---

### Ansible Deploy Workflow

**Purpose:** Deploy using Ansible playbooks

**Inputs:**
- `environment` (dev/prod)
- `image_tag` (e.g., latest, v1.0.0)

**What it does:**
1. ✅ Installs Python dependencies
2. ✅ Updates kubeconfig
3. ✅ Installs Ansible collections
4. ✅ Validates playbooks
5. ✅ Runs deployment playbook
6. ✅ Runs verification playbook
7. ✅ Checks deployment
8. ✅ Runs health check
9. ✅ Generates report

**Output:**
- Artifact: `ansible-deployment-report.txt`
- Contains: Pod status, services, endpoint
- Slack notification on success/failure
- Full Ansible execution logs

**Time:** ~10-15 minutes

---

### Deployment Status Workflow

**Purpose:** Check complete deployment status

**Inputs:**
- `environment` (dev/prod)

**What it does:**
1. ✅ Gets cluster info
2. ✅ Checks node status
3. ✅ Lists all pods
4. ✅ Gets pod metrics (CPU, memory)
5. ✅ Checks services
6. ✅ Checks deployments
7. ✅ Gets Helm status
8. ✅ Checks HPA status
9. ✅ Checks PVC status
10. ✅ Tests API endpoints
11. ✅ Shows recent logs
12. ✅ Generates report

**Output:**
- Artifact: `status-report-{env}.txt`
- Contains: Full deployment health
- Slack notification with summary
- Real-time status logs

**Time:** ~2-3 minutes

---

### Undeploy Workflow

**Purpose:** Remove services from cluster

**Inputs:**
- `environment` (dev/prod)
- `method` (helm, argocd, kubectl)

**What it does:**
1. ✅ Updates kubeconfig
2. ✅ Removes resources (using selected method)
3. ✅ Waits for cleanup
4. ✅ Verifies cleanup complete
5. ✅ Generates report

**Output:**
- Artifact: `undeploy-report-{env}.txt`
- Contains: Cleanup status
- Slack notification
- Cleanup logs

**Time:** ~2-5 minutes

**Methods:**
- **helm:** Helm uninstall (recommended)
- **argocd:** Delete ArgoCD application
- **kubectl:** Direct kubectl delete

---

## 🔄 Complete Workflow: From Code to Production

### Option A: Automated (Recommended)

```
1. Push code to main branch
2. GitHub Actions automatically:
   ├─ Build & test
   ├─ Push to ECR
   ├─ Deploy to dev
   ├─ Run integration tests
   ├─ Wait for approval
   └─ Deploy to prod
3. Monitor in Actions tab
```

### Option B: Manual with GitHub UI

```
1. Go to Actions
2. Select workflow:
   - "Deploy with Helm" (fastest)
   - "Deploy with ArgoCD" (GitOps, recommended)
   - "Deploy with Ansible" (orchestration)
3. Run workflow
4. Monitor execution
5. View results and logs
6. Download artifacts
```

### Option C: Hybrid

```
1. Automatic deployment to dev on push
2. Manual approval for prod deployment
3. Use workflows for manual tasks:
   - Setup ArgoCD
   - Check status
   - Undeploy if needed
```

---

## 📈 Features

### Automatic Features

✅ **AWS Authentication**
- Uses GitHub secrets
- No local AWS credentials

✅ **Notifications**
- Slack on success/failure
- With endpoint and status

✅ **Artifact Generation**
- Detailed reports
- Downloadable from UI

✅ **Real-time Logs**
- View execution in browser
- No terminal needed

✅ **Multi-environment**
- dev and prod support
- One workflow for all

✅ **Error Handling**
- Continues on non-critical errors
- Shows health checks

---

## 🔐 Secret Requirements

These secrets must be configured in GitHub:

```
AWS_ACCESS_KEY_ID          (For AWS authentication)
AWS_SECRET_ACCESS_KEY      (For AWS authentication)
ARGOCD_TOKEN               (For ArgoCD deployments)
GITHUB_TOKEN               (Auto-provided by GitHub)
SLACK_WEBHOOK_URL          (Optional, for notifications)
```

See: [GITHUB-SETUP.md](GITHUB-SETUP.md)

---

## 📊 Comparison: Methods

| Method | Speed | Control | GitOps | Best For |
|--------|-------|---------|--------|----------|
| **Helm** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ❌ | Quick testing |
| **Ansible** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ❌ | Infrastructure |
| **ArgoCD** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ | **Production** |
| **Auto CI/CD** | ⭐⭐ | ⭐⭐⭐⭐ | ✅ | **Recommended** |

---

## 🎯 Typical Deployment Flow

### Development Environment

```
1. Make code changes
2. Commit & push to develop branch
3. GitHub Actions:
   ├─ Run tests
   ├─ Build image
   ├─ Push to ECR
   └─ Auto-deploy to dev
4. View logs in Actions
5. Test in dev environment
```

### Production Environment

```
1. Create pull request to main
2. Get code review
3. Merge to main
4. GitHub Actions:
   ├─ Run full CI/CD
   ├─ Deploy to dev
   ├─ Run integration tests
   ├─ Wait for approval ⏸️
5. Approve in GitHub Actions
6. Auto-deploy to prod
7. Monitor status workflow
```

### Manual Deployment

```
1. Go to Actions
2. Select deployment workflow:
   - Helm Deploy (fastest)
   - ArgoCD Deploy (GitOps)
   - Ansible Deploy (orchestration)
3. Choose environment (dev/prod)
4. Enter image tag
5. Click "Run workflow"
6. Monitor in real-time
7. Download report
```

---

## 🚨 Troubleshooting

### "Workflow not found"
→ Go to `.github/workflows/` directory
→ Verify `.yml` files are there
→ Refresh Actions tab

### "Secrets not set"
→ Go to Settings > Secrets
→ Add missing secrets
→ See GITHUB-SETUP.md

### "Workflow failed"
→ Click workflow run
→ View logs for specific step
→ Check error messages
→ Verify prerequisites (cluster, credentials)

### "Deploy takes too long"
→ LoadBalancer IP pending → Wait 2-3 minutes
→ Pods not ready → Check logs
→ Resources exhausted → Check cluster

---

## 📚 Documentation Reference

| Document | Purpose |
|----------|---------|
| [GITHUB-SETUP.md](GITHUB-SETUP.md) | Configure secrets |
| [GITHUB-ACTIONS-WORKFLOWS.md](GITHUB-ACTIONS-WORKFLOWS.md) | This file |
| [CI-CD.md](CI-CD.md) | Full CI/CD pipeline |
| [STATUS-REPORT.md](STATUS-REPORT.md) | Project overview |

---

## ✨ Key Advantages

✅ **No local setup needed**
- No scripts to run locally
- No terminal required
- Browser-based management

✅ **Audit trail**
- Every action logged in GitHub
- Who deployed what when
- Full execution history

✅ **Consistency**
- Same deployment every time
- No variations from local differences
- Automated error handling

✅ **Scalability**
- Easy to add more workflows
- Reusable patterns
- Team collaboration ready

✅ **Notifications**
- Slack updates
- Real-time status
- Success/failure alerts

---

## 🎊 Summary

All operations now available via GitHub UI:

```
GitHub Actions Workflows (instead of shell scripts)

Setup:        setup-argocd.yml
Deploy:       helm-deploy.yml
             argocd-deploy.yml (recommended)
             ansible-deploy.yml
Status:       deployment-status.yml
Cleanup:      undeploy.yml
CI/CD:        microservices-cicd.yml (on push)
```

**No more local scripts needed!** Everything is managed through GitHub Actions! 🎉

---

## 🚀 Get Started

1. ✅ Configure GitHub Secrets ([GITHUB-SETUP.md](GITHUB-SETUP.md))
2. ✅ Go to Repository > Actions
3. ✅ Run "Setup ArgoCD" workflow
4. ✅ Run "Deploy with Helm" (or ArgoCD)
5. ✅ Monitor progress in browser
6. ✅ Download reports

**Everything from GitHub UI!** 🌐

---

Generated: June 2, 2026
Status: ✅ Ready for production
