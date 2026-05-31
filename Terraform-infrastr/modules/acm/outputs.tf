output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Domain name associated with the ACM certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "validation_record_fqdns" {
  description = "FQDNs for DNS validation records"
  value       = aws_route53_record.validation[*].fqdn
}
