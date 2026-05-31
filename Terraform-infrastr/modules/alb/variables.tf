variable "name" {
  description = "Name for the application load balancer"
  type        = string
  default     = "app-alb"
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the load balancer"
  type        = list(string)
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the load balancer"
  type        = string
  default     = "ipv4"
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS listener"
  type        = string
  default     = ""
}

variable "create_https_listener" {
  description = "Whether to create HTTPS listener"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for the target group"
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "Health check matcher for the target group"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold count for the target group"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count for the target group"
  type        = number
  default     = 2
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "tags" {
  description = "Tags to assign to ALB resources"
  type        = map(string)
  default     = {}
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}