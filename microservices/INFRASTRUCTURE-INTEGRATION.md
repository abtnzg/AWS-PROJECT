# Integration with AWS Infrastructure

This document explains how the microservices architecture integrates with your existing Terraform infrastructure.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet / Users                          │
└────────────────────────────┬────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   ALB (Route53) │
                    └────────┬────────┘
                             │
                ┌────────────┼────────────┐
                │                         │
         ┌──────▼────────┐       ┌───────▼──────┐
         │  Ingress ALB  │       │  HTTP/HTTPS  │
         └──────┬────────┘       └──────────────┘
                │
        ┌───────▼────────┐
        │  EKS Cluster   │
        └───────┬────────┘
                │
        ┌───────▼────────────────────────────┐
        │  Kubernetes Namespace: microservices│
        │                                     │
        │  ┌─────────────────────────────┐  │
        │  │   API Gateway (LB Service)  │  │
        │  └──────────┬──────────────────┘  │
        │             │                      │
        │    ┌────────┼────────┬────────┐   │
        │    │        │        │        │   │
        │  ┌─▼──┐ ┌──▼──┐ ┌──▼──┐ ┌──▼──┐ │
        │  │ US │ │ PS  │ │ OS  │ │ DB  │ │
        │  └────┘ └─────┘ └─────┘ └─────┘ │
        │                                   │
        └───────────────────────────────────┘
```

## Terraform Infrastructure Components

### 1. VPC (Virtual Private Cloud)
- **CIDR:** 10.0.0.0/16
- **Public Subnets:** 10.0.0.0/24, 10.0.1.0/24
- **Private Subnets:** 10.0.2.0/24, 10.0.3.0/24
- **Availability Zones:** eu-west-1a, eu-west-1b

**Integration:** EKS cluster runs in private subnets for security

### 2. EKS Cluster
- **Name:** aws-project-eks-dev
- **Region:** eu-west-1
- **Version:** As configured in Terraform

**Integration:** 
- Microservices deployed as Kubernetes workloads
- Worker nodes in private subnets with Security Group rules

### 3. ALB (Application Load Balancer)
- **Name:** aws-project-alb-dev
- **Type:** Application Load Balancer
- **Protocol:** HTTP/HTTPS (with ACM certificate)

**Integration:**
- External access point for the application
- Routes traffic to ALB Ingress Controller
- Health checks on microservices

### 4. ACM Certificate
- **Domain:** 205474062795.realhandsonlabs.net
- **Alternative Names:** *.205474062795.realhandsonlabs.net

**Integration:**
- HTTPS termination on ALB
- Ingress configuration references certificate

### 5. Security Groups
- **ALB SG:** Allows 80/443 from internet
- **EKS Node SG:** Allows inter-pod communication

**Integration:** EKS worker node SG configured to allow ALB to communicate with pods

### 6. Route 53
- **Hosted Zone:** Z04288871E0WCJH9AQH0L
- **Domain:** 205474062795.realhandsonlabs.net

**Integration:**
- Ingress creates Route 53 records via External DNS
- Auto DNS management for microservices

### 7. External DNS
- **Purpose:** Automatic Route 53 DNS record management
- **Configuration:** Deployed as Kubernetes workload

**Integration:** 
- Watches Ingress resources
- Automatically creates/updates Route 53 records
- Points to ALB endpoint

## Deployment Flow

### Step 1: Infrastructure Setup (Terraform)
```bash
cd Terraform-infrastr
terraform init -backend-config="inventories/dev/backend.hcl"
terraform plan -var-file="inventories/dev/terraform.tfvars"
terraform apply -var-file="inventories/dev/terraform.tfvars"
```

**Outputs:**
- EKS cluster endpoint
- ALB DNS name
- Security group IDs

### Step 2: Build Microservices
```bash
cd microservices
./scripts/build-and-push.sh 205474062795 eu-west-1 v1.0.0
```

**Outputs:**
- Docker images pushed to ECR
- Image URIs for Kubernetes manifests

### Step 3: Deploy Microservices
```bash
./scripts/deploy.sh 205474062795 dev microservices
```

**Process:**
1. Creates namespace
2. Deploys MySQL
3. Deploys microservices
4. Creates Ingress
5. Configures HPA and network policies

### Step 4: Access Application
```
https://api.205474062795.realhandsonlabs.net
```

## Network Communication

### Internal Communication
- **Pod to Pod:** Direct via Service DNS (e.g., `user-service:3001`)
- **Service Discovery:** Kubernetes DNS (CoreDNS)

### External Communication
```
Internet → Route 53 → ALB → Ingress → API Gateway Pod → Other Services
```

## Data Flow

### Request Flow
```
1. Client → Route 53 (API domain lookup)
2. Route 53 → ALB IP
3. Client → ALB:443 (HTTPS request)
4. ALB → Ingress Controller (in EKS)
5. Ingress → API Gateway Service (ClusterIP)
6. API Gateway Pod → Other Service Pods (via Service DNS)
7. Service Pods → MySQL (via Service DNS)
```

## Environment-Specific Configuration

### Development (dev)
```yaml
Environment: dev
VPC CIDR: 10.0.0.0/16
Replicas: 2
Max Replicas: 5
DB Instance: MySQL 8.0
ALB: Single availability zone redundancy
```

### Other Environments (qua, rec, prod)
Similar configuration with environment-specific:
- CIDR ranges
- Replica counts
- Database sizes
- SSL/TLS settings

## Updating Infrastructure

### Scaling Services
```bash
# Automatic scaling configured via HPA
# Manual scaling if needed:
kubectl scale deployment api-gateway --replicas=3 -n microservices
```

### Updating Terraform Variables
```bash
# Edit the appropriate terraform.tfvars
vim Terraform-infrastr/inventories/dev/terraform.tfvars

# Plan and apply changes
terraform plan -var-file="inventories/dev/terraform.tfvars"
terraform apply -var-file="inventories/dev/terraform.tfvars"
```

### Redeploying Microservices
```bash
# Update image tags
./scripts/build-and-push.sh 205474062795 eu-west-1 v1.0.1

# Trigger rollout
kubectl rollout restart deployment -n microservices

# Monitor rollout
kubectl rollout status deployment api-gateway -n microservices
```

## Monitoring and Logs

### CloudWatch Logs
```bash
# View EKS cluster logs
aws logs tail /aws/eks/aws-project-eks-dev/cluster --follow

# View container logs
aws logs tail /aws/eks/aws-project-eks-dev/containers --follow
```

### Kubernetes Logs
```bash
# All pod logs
kubectl logs -f -l app=api-gateway -n microservices

# Specific pod logs
kubectl logs -f <pod-name> -n microservices
```

### CloudWatch Metrics
- EKS cluster metrics
- ALB request count
- Target health
- Network performance

## Troubleshooting

### Service Not Accessible
1. Check Route 53 records
2. Verify ALB target health
3. Check Ingress configuration
4. Verify Security Groups

### Pod Communication Issues
1. Check network policies
2. Verify service DNS names
3. Check pod logs
4. Verify service endpoints

### Database Connection Issues
1. Check MySQL pod status
2. Verify database credentials
3. Check MySQL service endpoint
4. Verify PVC status

## Backup and Recovery

### Database Backups
```bash
# Manual backup
kubectl exec -it mysql-<pod-id> -n microservices -- \
  mysqldump -u root -p all-databases > backup.sql
```

### Infrastructure Backups
```bash
# Terraform state backup
aws s3 cp s3://aws-project-terraform-state/terraform-dev.tfstate ./backup/
```

## Cost Optimization

### Current Setup
- t3.medium instances (EKS nodes)
- ALB (hourly charge)
- MySQL RDS equivalent storage
- NAT Gateway charges

### Optimization Recommendations
1. Use Spot instances for non-critical workloads
2. Enable ALB access logs for troubleshooting
3. Configure lifecycle policies for logs
4. Use Reserved Instances for baseline capacity
5. Implement resource quotas per namespace

## Security Best Practices

✅ **Implemented:**
- Network policies for pod-to-pod communication
- Security groups for ALB
- IAM roles for service accounts
- TLS/SSL termination

🔒 **Recommended Additions:**
- Pod Security Policies
- RBAC policies
- Container scanning
- Runtime security monitoring
- Secrets encryption at rest
- VPC Flow Logs

## Related Documentation

- [Terraform Infrastructure](../Terraform-infrastr/README.md)
- [Microservices README](./README.md)
- [Development Guide](./DEVELOPMENT.md)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
