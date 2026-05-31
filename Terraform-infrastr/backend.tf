terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "aws-project-terraform-state"
    key            = "Terraform-infrastr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
