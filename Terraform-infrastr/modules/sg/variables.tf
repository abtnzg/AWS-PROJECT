variable "name" {
  description = "Name of the security group"
  type        = string
  default     = "sg"
}

variable "description" {
  description = "Security group description"
  type        = string
  default     = "Managed security group"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type        = list(map(any))
  default     = []
}

variable "egress_rules" {
  description = "Egress rules for the security group"
  type        = list(map(any))
  default     = []
}

variable "tags" {
  description = "Tags to apply to security group resources"
  type        = map(string)
  default     = {}
}
