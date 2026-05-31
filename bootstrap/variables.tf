variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "aws-project-terraform-state"
}

variable "locks_table_name" {
  description = "DynamoDB table name for state locks"
  type        = string
  default     = "terraform-state-locks"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "aws-project"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}
