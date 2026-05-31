aws_region = "eu-west-3"

vpc_name = "aws-project-vpc-prod"
vpc_cidr = "10.3.0.0/16"
public_subnet_cidrs = ["10.3.0.0/24", "10.3.1.0/24"]
private_subnet_cidrs = ["10.3.2.0/24", "10.3.3.0/24"]
availability_zones = ["eu-west-3a", "eu-west-3b"]

eks_cluster_name = "aws-project-eks-prod"

alb_name = "aws-project-alb-prod"

route53_zone_id = "Z1234567890ABC"
domain_name = "prod.example.com"
san_names = ["*.prod.example.com"]

external_dns_hosted_zone_ids = ["Z1234567890ABC"]

tags = {
  Project     = "aws-project"
  Environment = "prod"
}
