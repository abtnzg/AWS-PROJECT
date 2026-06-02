aws_region = "us-east-1"

vpc_name             = "aws-project-vpc-dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

eks_cluster_name = "aws-project-eks-dev"

alb_name = "aws-project-alb-dev"

route53_zone_id = ""  # Validation EMAIL au lieu de DNS (permissions insuffisantes)
domain_name     = "789051085078.realhandsonlabs.net"
san_names       = ["*.789051085078.realhandsonlabs.net"]

external_dns_hosted_zone_ids = ["Z03284841TXS8G0UV28EC"]

enable_https = true

tags = {
  Environment = "dev"
}
