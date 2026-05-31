output "role_arn" {
  description = "IAM role ARN for external-dns service account"
  value       = aws_iam_role.external_dns.arn
}

output "role_name" {
  description = "IAM role name for external-dns"
  value       = aws_iam_role.external_dns.name
}

output "policy_arn" {
  description = "IAM policy ARN for external-dns Route53 permissions"
  value       = aws_iam_policy.external_dns.arn
}

output "service_account_annotation" {
  description = "Annotation map to apply to the external-dns Kubernetes service account"
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
  }
}
