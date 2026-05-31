aws_region = "eu-west-3"

vpc_name             = "aws-project-vpc-rec"
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.0.0/24", "10.2.1.0/24"]
private_subnet_cidrs = ["10.2.2.0/24", "10.2.3.0/24"]
availability_zones   = ["eu-west-3a", "eu-west-3b"]

eks_cluster_name = "aws-project-eks-rec"

alb_name = "aws-project-alb-rec"

route53_zone_id = "Z07837731K16F2Z68USQL"
domain_name     = "851725468573.realhandsonlabs.net"
san_names       = ["*.851725468573.realhandsonlabs.net"]

external_dns_hosted_zone_ids = ["Z07837731K16F2Z68USQL"]

tags = {
  Project     = "aws-project"
  Environment = "rec"
}
