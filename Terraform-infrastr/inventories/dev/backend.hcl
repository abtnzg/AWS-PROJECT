bucket         = "aws-project-terraform-state"
key            = "Terraform-infrastr/inventories/dev/terraform.tfstate"
region         = "eu-west-3"
dynamodb_table = "terraform-state-locks"
encrypt        = true
