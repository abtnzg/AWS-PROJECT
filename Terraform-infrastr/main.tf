locals {
  common_tags = merge({ project = "aws-project" }, var.tags)
}

module "vpc" {
  source               = "./modules/vpc"
  name                 = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = local.common_tags
}

module "alb_sg" {
  source      = "./modules/sg"
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from internet"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from internet"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
  tags = local.common_tags
}

module "acm" {
  source          = "./modules/acm"
  domain_name     = var.domain_name
  san_names       = var.san_names
  route53_zone_id = var.route53_zone_id
  tags            = local.common_tags
}

module "alb" {
  source                = "./modules/alb"
  name                  = var.alb_name
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_ids    = [module.alb_sg.security_group_id]
  certificate_arn       = module.acm.certificate_arn
  create_https_listener = var.enable_https
  tags                  = local.common_tags
}

module "eks" {
  source                = "./modules/eks"
  eks_cluster_name      = var.eks_cluster_name
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb_sg.security_group_id
  vpc_id                = module.vpc.vpc_id
}

module "external_dns" {
  source            = "./modules/external_dns"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  hosted_zone_ids   = var.external_dns_hosted_zone_ids
  tags              = local.common_tags
}
