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
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "tags" {
  description = "Tags to apply to security group resources"
  type        = map(string)
  default     = {}
}
