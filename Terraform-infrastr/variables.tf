variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "aws-project-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnet placement"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "aws-project-eks"
}

variable "alb_name" {
  description = "Name for the application load balancer"
  type        = string
  default     = "aws-project-alb"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID used for ACM validation"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the ACM certificate"
  type        = string
}

variable "san_names" {
  description = "Subject alternative names for ACM certificate"
  type        = list(string)
  default     = []
}

variable "external_dns_hosted_zone_ids" {
  description = "Route53 hosted zone IDs that external-dns is allowed to manage"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
