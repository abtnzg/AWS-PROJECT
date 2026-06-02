# 🌐 GitHub UI Guide - Accessing Your Workflows

Complete visual guide to accessing and running workflows from GitHub interface!

---

## 📍 Step-by-Step Navigation

### Step 1: Go to Your Repository
```
1. Open: https://github.com/YOUR_USERNAME/AWS-PROJECT
2. You're now on the main repository page
```

### Step 2: Click "Actions" Tab
```
Location: Top navigation bar
├─ Code  |  Issues  |  Pull requests  |  [ACTIONS] ← Click here
└─ This shows all workflows
```

### Step 3: Select a Workflow
```
Left sidebar shows all workflows:
├─ Setup ArgoCD
├─ Deploy with Helm
├─ Deploy with ArgoCD (RECOMMENDED)
├─ Deploy with Ansible
├─ Deployment Status
├─ Undeploy Services
├─ Full CI/CD Pipeline
└─ Terraform Destroy/Apply
```

### Step 4: Click "Run workflow"
```
Big blue button appears:
├─ "Run workflow" dropdown (with arrow)
└─ Click the button
```

### Step 5: Configure Inputs (if any)
```
Form appears:
├─ environment: Choose dev or prod
├─ image_tag: Type the tag (e.g., latest)
└─ force_sync: Toggle if needed
```

### Step 6: Run!
```
Click: "Run workflow" button
└─ Workflow starts immediately
```

### Step 7: Monitor Execution
```
Watch in real-time:
├─ Each job runs step-by-step
├─ Logs stream live
├─ See output in real-time
├─ Watch status changes
└─ No refresh needed (auto-updates)
```

### Step 8: Download Results
```
After completion:
├─ Scroll down to "Artifacts"
├─ Click "Download" button
├─ Open .txt file
├─ Review complete report
```

---

## 🎬 Visual Workflow

```
┌─────────────────────────────────────────────────────────┐
│ GitHub Repository Page                                  │
│                                                         │
│ [Code] [Issues] [Pull requests] [Actions]              │
│                               ↓ Click here              │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│ Actions Tab                                             │
│                                                         │
│ Left Sidebar:             Main Area:                    │
│ ┌────────────────┐        ┌────────────────┐           │
│ │ All workflows: │        │ Select a       │           │
│ │               │        │ workflow from  │           │
│ │ • Setup       │        │ left sidebar   │           │
│ │ • Helm Deploy │        │                │           │
│ │ • ArgoCD ⭐    │ Click  │ "Run workflow" │ Click     │
│ │ • Ansible     │  →→→   │ button appears │   →→→     │
│ │ • Status      │        │                │           │
│ │ • Undeploy    │        │ Fill in inputs │           │
│ │               │        │ if needed      │           │
│ └────────────────┘        └────────────────┘           │
│                                                         │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│ Input Form (if needed)                                  │
│                                                         │
│ environment: [dev ▼]                                    │
│ image_tag: [latest]                                    │
│ force_sync: [  ] (toggle)                              │
│                                                         │
│ [Cancel] [Run workflow]                                 │
│                         ↓ Click                         │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│ Workflow Running                                        │
│                                                         │
│ Status: 🟡 In progress                                  │
│                                                         │
│ Jobs:                                                   │
│ ✅ Checkout code                                        │
│ ✅ Setup AWS credentials                               │
│ ✅ Update kubeconfig                                    │
│ 🟡 Deploy services (running...)                         │
│ ⏸️ Wait for deployment                                  │
│ ⏳ Verify deployment                                    │
│                                                         │
│ 📝 Live Logs:                                           │
│ > kubectl get pods                                      │
│ > pod is running                                        │
│ > deployment successful                                │
│ > ...                                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│ Workflow Complete                                       │
│                                                         │
│ Status: ✅ Success                                      │
│                                                         │
│ Jobs:                                                   │
│ ✅ Checkout code                                        │
│ ✅ Setup AWS credentials                               │
│ ✅ Update kubeconfig                                    │
│ ✅ Deploy services                                      │
│ ✅ Wait for deployment                                  │
│ ✅ Verify deployment                                    │
│                                                         │
│ 📥 Artifacts:                                           │
│ [⬇️ Download] helm-deployment-report.txt               │
│ [⬇️ Download] status-report.txt                         │
│                                                         │
│ 🔔 Slack Notification sent!                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
                              ↓
                    ✅ Done! Deployment complete!
```

---

## 🔐 Configure Secrets (One-Time Setup)

### Location
```
Repository > Settings > Secrets and variables > Actions
```

### Add Each Secret

1. Click "New repository secret"
2. Fill in:
   - **Name:** AWS_ACCESS_KEY_ID
   - **Value:** Your AWS access key
3. Click "Add secret"

Repeat for:
- `AWS_SECRET_ACCESS_KEY` (your AWS secret)
- `ARGOCD_TOKEN` (generate after setup-argocd runs)
- `SLACK_WEBHOOK_URL` (optional, for notifications)
- `GITHUB_TOKEN` (usually auto-provided)

---

## 📊 Real-Time Monitoring

### While Workflow Runs

```
✅ What you see:
├─ Each job listed with status
├─ Log output streams live
├─ Progress bar moves
├─ Colors change (yellow=running, green=done)
├─ Can expand/collapse each section
└─ Auto-refreshes every few seconds

❌ What NOT to do:
├─ Don't close the browser
├─ Don't refresh manually
├─ Don't cancel unless needed
└─ Don't expect instant completion
```

### Expand Logs

```
1. Click any job/step name
   └─ Shows detailed logs for that step
2. View real-time output
   └─ kubectl commands, build output, etc.
3. Search within logs
   └─ Ctrl+F to find specific text
```

---

## 📥 Download Artifacts

### After Workflow Completes

```
1. Go to: Workflow run details page
2. Scroll down to "Artifacts" section
3. See list of files:
   ├─ helm-deployment-report.txt
   ├─ status-report-dev.txt
   └─ argocd-setup-report.txt
4. Click [⬇️ Download]
5. File downloads to your Downloads folder
6. Open in any text editor
7. Review complete deployment details
```

### What's in Reports?

```
Typical Report Content:
├─ Deployment Status
├─ Pod Information
├─ Service Details
├─ Resource Usage
├─ Health Check Results
├─ API Endpoints
├─ Error Messages (if any)
└─ Execution Summary
```

---

## 🔔 Slack Notifications

### What You Get (If Configured)

```
Message Format:
┌─────────────────────────────┐
│ 🟢 AWS-PROJECT Deployment   │
│    Workflow: Deploy w/ Helm │
│    Status: SUCCESS          │
│    Duration: 8 minutes      │
│    API: http://...          │
│    Pods: 4/4 running        │
│    Author: @username        │
│    View: [GitHub Link]      │
└─────────────────────────────┘
```

---

## ⏱️ Workflow Duration

```
Typical Times:

Setup ArgoCD:        ⏱️ 5-10 minutes
Deploy with Helm:    ⏱️ 5-10 minutes
Deploy with ArgoCD:  ⏱️ 10-15 minutes
Deploy with Ansible: ⏱️ 10-15 minutes
Check Status:        ⏱️ 2-3 minutes
Undeploy:            ⏱️ 2-5 minutes
Full CI/CD:          ⏱️ 20-30 minutes

⚠️ First time may be slightly slower
✅ Subsequent runs typically faster
```

---

## 🆘 Troubleshooting

### "Workflow not visible"
→ Refresh the Actions page
→ Check `.github/workflows/` directory exists
→ Wait a few minutes for GitHub to detect workflows

### "Input fields not showing"
→ Scroll down on the form
→ Some inputs are optional
→ Check workflow YAML for required inputs

### "Download button missing"
→ Workflow must complete successfully
→ Check job status (green checkmark)
→ Artifacts only available after completion
→ Some workflows may not generate artifacts

### "Execution error"
→ Check logs for specific error message
→ Read the red error text
→ Search error in documentation
→ Check GitHub Secrets are configured

---

## 📚 Documentation Reference

All workflows can be run directly from GitHub UI!

| Workflow | Path | Time |
|----------|------|------|
| Setup ArgoCD | Actions > Setup ArgoCD | 10 min |
| Helm Deploy | Actions > Deploy with Helm | 10 min |
| ArgoCD Deploy | Actions > Deploy with ArgoCD | 15 min |
| Ansible Deploy | Actions > Deploy with Ansible | 15 min |
| Check Status | Actions > Deployment Status | 3 min |
| Undeploy | Actions > Undeploy Services | 5 min |

---

## ✨ Tips & Tricks

### Bookmark Important Workflows
```
Save to browser:
https://github.com/YOUR_USER/AWS-PROJECT/actions/workflows/argocd-deploy.yml
```

### Share Workflow Status
```
Copy the workflow run URL from address bar
Send to team members
They can view progress without access
```

### Rerun Failed Workflow
```
If workflow fails:
1. Go to failed workflow run
2. Click "Re-run jobs"
3. Select jobs to rerun
4. Click "Re-run jobs"
5. Workflow executes again
```

### Keep History
```
GitHub keeps workflow history:
├─ Shows all past runs
├─ Success and failures
├─ Execution times
└─ Artifacts available for 90 days
```

---

## 🎯 Common Workflows

### Quick Dev Deploy
```
1. Actions
2. "Deploy with Helm"
3. environment: dev
4. image_tag: latest
5. Run workflow
6. ✅ Done in 10 minutes!
```

### Production Deployment (Safe)
```
1. Actions
2. "Deploy with ArgoCD" (RECOMMENDED)
3. environment: prod
4. image_tag: v1.0.0
5. force_sync: false
6. Run workflow
7. ✅ GitOps-based deployment!
```

### Check Everything
```
1. Actions
2. "Deployment Status"
3. environment: prod
4. Run workflow
5. ✅ Full health report in 3 minutes!
```

---

## 🔗 Quick Links

### GitHub Pages
```
Repository Home:
https://github.com/YOUR_USER/AWS-PROJECT

Actions Tab:
https://github.com/YOUR_USER/AWS-PROJECT/actions

Settings (Secrets):
https://github.com/YOUR_USER/AWS-PROJECT/settings/secrets
```

---

## 🎓 Learning Path

### Beginner
```
1. Read: WORKFLOWS-QUICK-REFERENCE.md
2. Do: Run setup-argocd.yml
3. Do: Run helm-deploy.yml
4. Check: deployment-status.yml
```

### Intermediate
```
1. Read: GITHUB-ACTIONS-WORKFLOWS.md
2. Try: All deployment methods
3. Monitor: Real-time execution
4. Download: Reports and artifacts
```

### Advanced
```
1. Modify: Workflow inputs
2. Create: Custom parameters
3. Automate: Scheduled deployments
4. Monitor: Full CI/CD pipeline
```

---

## ✅ You Can Do This!

No command line needed!
No terminal experience required!
Just browser and a few clicks!

Ready? Let's go! 🚀

```
1. Go to: Repository > Actions
2. Select: Any workflow
3. Click: "Run workflow"
4. Watch: Real-time execution
5. Download: Results
6. Done! ✅
```

---

**Last Updated:** June 2, 2026  
**Status:** ✅ Ready for All Users
