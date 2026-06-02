bucket         = "aws-project-terraform-state"
key            = "Terraform-infrastr/inventories/prod/terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
