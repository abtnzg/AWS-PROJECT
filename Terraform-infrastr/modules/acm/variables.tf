variable "domain_name" {
  description = "Primary domain name for the ACM certificate"
  type        = string
}

variable "san_names" {
  description = "Subject alternative names"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID used for DNS validation"
  type        = string
}

variable "tags" {
  description = "Tags to assign to ACM resources"
  type        = map(string)
  default     = {}
}
