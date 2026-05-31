aws_region = "us-east-1"

vpc_name             = "aws-project-vpc-qua"
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.2.0/24", "10.1.3.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

eks_cluster_name = "aws-project-eks-qua"

alb_name = "aws-project-alb-qua"

route53_zone_id = "Z07837731K16F2Z68USQL"
domain_name     = "851725468573.realhandsonlabs.net"
san_names       = ["*.851725468573.realhandsonlabs.net"]

external_dns_hosted_zone_ids = ["Z07837731K16F2Z68USQL"]

enable_https = true

tags = {
  Project     = "aws-project"
  Environment = "qua"
}
