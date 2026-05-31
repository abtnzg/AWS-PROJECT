variable "name" {
  description = "Name prefix for external-dns IAM resources"
  type        = string
  default     = "external-dns"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider (https://... )"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account used by external-dns"
  type        = string
  default     = "external-dns"
}

variable "service_account_namespace" {
  description = "Namespace of the Kubernetes service account used by external-dns"
  type        = string
  default     = "external-dns"
}

variable "hosted_zone_ids" {
  description = "Route53 hosted zone IDs that external-dns is allowed to manage. Leave empty to allow all zones."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
