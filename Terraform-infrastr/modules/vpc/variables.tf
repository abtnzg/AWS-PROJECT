variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "project-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnet placement"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(string)
  default     = {}
}
