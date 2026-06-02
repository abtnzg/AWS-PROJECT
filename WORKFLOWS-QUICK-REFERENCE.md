# 🎯 GitHub Actions Workflows - Quick Reference Card

Complete guide to managing your microservices deployment entirely through GitHub UI!

## ✅ Prerequisites (One-Time Setup)

```
1. Configure GitHub Secrets:
   ├─ AWS_ACCESS_KEY_ID
   ├─ AWS_SECRET_ACCESS_KEY
   ├─ ARGOCD_TOKEN (after setup-argocd completes)
   ├─ GITHUB_TOKEN (auto-provided)
   └─ SLACK_WEBHOOK_URL (optional)
   
   Location: Repository > Settings > Secrets

2. That's it! All workflows are ready to use!
```

---

## 🚀 Workflow Access (GitHub UI)

### How to Run Any Workflow

```
1. Go to: Repository home
2. Click: "Actions" tab
3. Select workflow from left panel
4. Click: "Run workflow"
5. Fill input fields (if any)
6. Click: "Run workflow" button
7. Monitor progress in real-time
8. View results and artifacts
```

---

## 📋 Available Workflows

### 1️⃣ Setup ArgoCD
**Location:** `.github/workflows/setup-argocd.yml`

```
Purpose: Install ArgoCD on EKS cluster

Inputs:
  cluster_name    → aws-project-eks-dev
  aws_region      → eu-west-1

Duration: ~5-10 min
Output:   argocd-setup-report.txt (artifact)

Use When: First time setup
```

### 2️⃣ Deploy with Helm ⚡
**Location:** `.github/workflows/helm-deploy.yml`

```
Purpose: Deploy services using Helm (fastest)

Inputs:
  environment  → dev or prod
  image_tag    → latest (or specific tag)

Duration: ~5-10 min
Output:   helm-deployment-report.txt

Use When: Quick deployment, direct control
```

### 3️⃣ Deploy with ArgoCD 🔄 (RECOMMENDED)
**Location:** `.github/workflows/argocd-deploy.yml`

```
Purpose: Deploy using GitOps (Git-driven)

Inputs:
  environment  → dev or prod
  image_tag    → latest
  force_sync   → false (or true to override)

Duration: ~10-15 min
Output:   argocd-deployment-report.txt

Use When: Production deployment
         Git-driven deployment
         Easy rollback needed
```

### 4️⃣ Deploy with Ansible 🤖
**Location:** `.github/workflows/ansible-deploy.yml`

```
Purpose: Deploy using Ansible (orchestration)

Inputs:
  environment  → dev or prod
  image_tag    → latest

Duration: ~10-15 min
Output:   ansible-deployment-report.txt

Use When: Complex orchestration needed
         Infrastructure as code
         Detailed control
```

### 5️⃣ Check Deployment Status 📊
**Location:** `.github/workflows/deployment-status.yml`

```
Purpose: View complete deployment health

Inputs:
  environment  → dev or prod

Duration: ~2-3 min
Output:   status-report-{env}.txt

Use When: Check pod status
         Monitor resources
         Troubleshoot issues
```

### 6️⃣ Undeploy Services 🗑️
**Location:** `.github/workflows/undeploy.yml`

```
Purpose: Remove services from cluster

Inputs:
  environment  → dev or prod
  method       → helm | argocd | kubectl

Duration: ~2-5 min
Output:   undeploy-report-{env}.txt

Use When: Remove test deployment
         Clean up environment
         Start fresh
```

### 7️⃣ Auto CI/CD (On Push)
**Location:** `.github/workflows/microservices-cicd.yml`

```
Purpose: Automated on every push to main/develop

Triggers:
  ✓ Push to main/develop
  ✓ Pull requests to main
  ✓ Manual dispatch

Stages:
  1. Build & Test
  2. Push to ECR
  3. Validate Helm
  4. Deploy Dev (automatic)
  5. Integration Tests
  6. Deploy Prod (manual approval)
  7. Notifications

Duration: ~20-30 min (full pipeline)

Use When: Code is pushed to main/develop
         Automatic CI/CD activation
```

---

## 🎬 Common Scenarios

### Scenario 1: First-Time Setup

```
Step 1: Setup ArgoCD
├─ Go to Actions > Setup ArgoCD
├─ Click: Run workflow
├─ Wait: ~10 minutes
├─ Download: argocd-setup-report.txt
└─ Get: Admin password and setup instructions

Step 2: Add ARGOCD_TOKEN to Secrets
├─ Login to ArgoCD
├─ Generate token
├─ Add to GitHub Secrets

Step 3: Done! ✅ Ready to deploy
```

### Scenario 2: Deploy to Dev (Testing)

```
Step 1: Choose Method
├─ "Deploy with Helm" (fastest - 5 min)
└─ "Deploy with ArgoCD" (best practice - 10 min)

Step 2: Run Workflow
├─ Go to Actions
├─ Select workflow
├─ Inputs:
│  ├─ environment: dev
│  └─ image_tag: latest
├─ Click: Run workflow
└─ Wait for completion

Step 3: Get Endpoint
├─ Check logs for API endpoint
├─ Or run: "Deployment Status" workflow
├─ Download report
└─ Test: curl http://<endpoint>/health

Step 4: Done! ✅ Dev is running
```

### Scenario 3: Deploy to Production

```
Step 1: Code Ready in Main
├─ Code merged to main
├─ All checks passed
└─ Ready for production

Step 2: Automatic Deployment (Recommended)
├─ GitHub Actions auto-deploys to dev
├─ Integration tests run
├─ Manual approval requested
├─ Click: "Approve" in workflow
└─ Auto-deploys to prod

Step 3: Manual Deployment Alternative
├─ Go to Actions
├─ Select: Deploy with ArgoCD (recommended)
├─ Inputs:
│  ├─ environment: prod
│  └─ image_tag: v1.0.0
├─ Click: Run workflow
└─ Wait for completion

Step 4: Verify Production
├─ Run: "Deployment Status" workflow
├─ Select: prod
├─ Download report
├─ Verify API responding
└─ Done! ✅ Prod is live
```

### Scenario 4: Check What's Running

```
Go to Actions > Deployment Status
├─ Inputs: environment (dev or prod)
├─ Click: Run workflow
├─ Wait: ~3 minutes
├─ View: Complete health status
├─ Check:
│  ├─ Pod status (running/pending)
│  ├─ Resource usage (CPU/memory)
│  ├─ Services and endpoints
│  ├─ API health check
│  └─ Recent logs
├─ Download: Detailed report
└─ All info in browser! ✅
```

### Scenario 5: Remove Old Deployment

```
Go to Actions > Undeploy Services
├─ Inputs:
│  ├─ environment: dev or prod
│  └─ method: helm (recommended)
├─ Click: Run workflow
├─ Wait: ~3 minutes
├─ Verify: All services removed
├─ Download: Cleanup report
└─ Clean slate! ✅
```

---

## 🔄 Deployment Flow Diagram

```
┌─────────────────────────────────────────┐
│     Your GitHub Repository              │
│                                         │
│  Code > Push to Main                    │
│    │                                    │
│    └──> Automatic Trigger               │
│         microservices-cicd.yml          │
│         ├─ Build & Test                 │
│         ├─ Push to ECR                  │
│         ├─ Deploy Dev                   │
│         ├─ Test                         │
│         └─ Await Approval               │
│                                         │
│  OR Manual Workflows:                   │
│    ├─ Setup ArgoCD                      │
│    ├─ Deploy with Helm                  │
│    ├─ Deploy with ArgoCD (Recommended)  │
│    ├─ Deploy with Ansible               │
│    ├─ Check Status                      │
│    └─ Undeploy                          │
│                                         │
└────────────────┬────────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  EKS Cluster   │
        │  (AWS)         │
        │                │
        │ Namespaces:    │
        │ ├─ microservices
        │ ├─ argocd      │
        │ └─ kube-system │
        │                │
        │ Services:      │
        │ ├─ API Gateway │
        │ ├─ Helm/etc    │
        │ └─ MySQL       │
        └────────────────┘
```

---

## 📊 Monitoring & Artifacts

### While Workflow is Running

```
Real-time Updates:
✓ Logs stream in browser
✓ Each step shows progress
✓ Errors highlighted immediately
✓ No terminal needed
✓ Can close browser and check later
```

### After Workflow Completes

```
Artifacts Available:
✓ Deployment reports (TXT files)
✓ Can download for records
✓ Includes status, endpoints, resources
✓ Keep for audit trail
✓ Link to workflow in GitHub
```

### Access Artifacts

```
1. Go to: Workflow run details
2. Scroll to: "Artifacts" section
3. Click: Download button
4. Open: TXT file in any editor
5. Review: Complete details
```

---

## ⏱️ Time Estimates

| Workflow | Duration | Notes |
|----------|----------|-------|
| setup-argocd | 5-10 min | One-time setup |
| helm-deploy | 5-10 min | Fast, direct |
| argocd-deploy | 10-15 min | Includes git sync |
| ansible-deploy | 10-15 min | Full orchestration |
| status-check | 2-3 min | Quick check |
| undeploy | 2-5 min | Quick cleanup |
| CI/CD full | 20-30 min | Automatic on push |

---

## 🎯 Best Practices

### ✅ Do

```
✓ Use ArgoCD for production (GitOps)
✓ Use Helm for quick testing
✓ Check status before making changes
✓ Keep image tags semantic (v1.0.0)
✓ Review reports and artifacts
✓ Use proper environment names (dev/prod)
✓ Monitor Slack notifications
```

### ❌ Don't

```
✗ Use root/production credentials locally
✗ Skip Helm chart validation
✗ Deploy without checking status
✗ Use "latest" for production
✗ Ignore workflow failures
✗ Force sync if out of sync
✗ Skip approval steps
```

---

## 🔐 Security

All workflows use:
- ✅ GitHub Secrets (encrypted)
- ✅ AWS IAM roles
- ✅ Least privilege access
- ✅ HTTPS only
- ✅ No credentials in code
- ✅ Audit logging

---

## 🆘 Troubleshooting

### Workflow not found
→ Check `.github/workflows/` exists
→ Verify file names
→ Refresh Actions tab

### Secret not found error
→ Settings > Secrets
→ Add missing secret
→ Verify name matches exactly

### Deployment failing
→ Check logs in workflow run
→ Verify cluster is accessible
→ Check pod events
→ Run status check workflow

### Long wait time
→ LoadBalancer IP pending? Wait 2-3 min
→ Pods pending? Check resources
→ Check cluster logs

---

## 📚 Related Documentation

| Document | Purpose |
|----------|---------|
| [GITHUB-SETUP.md](../microservices/GITHUB-SETUP.md) | Configure secrets |
| [GITHUB-ACTIONS-WORKFLOWS.md](../GITHUB-ACTIONS-WORKFLOWS.md) | Full workflow guide |
| [CI-CD.md](../microservices/CI-CD.md) | Pipeline details |
| [STATUS-REPORT.md](../microservices/STATUS-REPORT.md) | Project overview |

---

## 🚀 Get Started Now

```
1. Go to: Repository > Actions tab
2. Select: Any workflow (e.g., "Setup ArgoCD")
3. Click: "Run workflow"
4. Watch: Real-time execution
5. Download: Results and reports
6. Done! ✅

Everything from GitHub UI, no local scripts needed!
```

---

## 🎉 Summary

| Old Way | New Way |
|---------|---------|
| Run scripts locally | Run workflows in GitHub UI |
| Terminal required | Browser only |
| Manual setup | Automated setup |
| Limited logging | Full real-time logs |
| File downloads | Artifact downloads |
| Email results | Slack notifications |

**Everything is now managed through GitHub Actions!** 🌐

---

**Generated:** June 2, 2026  
**Status:** ✅ Ready for Production  
**Last Updated:** With 6 new workflows
