variable "repository_name" {
  description = "The name of the ECR repository to create"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for the ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether image scanning should be enabled on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the ECR repository"
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "A map of tags to assign to repository resources"
  type        = map(string)
  default     = {}
}
