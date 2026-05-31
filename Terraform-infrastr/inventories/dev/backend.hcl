bucket         = "aws-project-terraform-state"
key            = "Terraform-infrastr/inventories/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
