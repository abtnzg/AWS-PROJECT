output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "locks_table_name" {
  description = "DynamoDB table name for state locks"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "locks_table_arn" {
  description = "DynamoDB table ARN for state locks"
  value       = aws_dynamodb_table.terraform_locks.arn
}
