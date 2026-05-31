output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.eks_cluster_name
}

output "external_dns_role_arn" {
  description = "IAM role ARN for external-dns"
  value       = module.external_dns.role_arn
}
