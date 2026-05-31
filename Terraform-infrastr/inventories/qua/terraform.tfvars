aws_region = "eu-west-3"

vpc_name = "aws-project-vpc-qua"
vpc_cidr = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.2.0/24", "10.1.3.0/24"]
availability_zones = ["eu-west-3a", "eu-west-3b"]

eks_cluster_name = "aws-project-eks-qua"

alb_name = "aws-project-alb-qua"

route53_zone_id = "Z1234567890ABC"
domain_name = "qua.example.com"
san_names = ["*.qua.example.com"]

external_dns_hosted_zone_ids = ["Z1234567890ABC"]

tags = {
  Project     = "aws-project"
  Environment = "qua"
}
