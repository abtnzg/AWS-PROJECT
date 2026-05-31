locals {
  hosted_zone_arns = [for id in var.hosted_zone_ids : "arn:aws:route53:::hostedzone/${id}"]
  route53_resources = length(local.hosted_zone_arns) > 0 ? local.hosted_zone_arns : ["*"]
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.name}-route53-policy"
  description = "Route53 permissions for external-dns"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
        ]
        Resource = local.route53_resources
      }
    ]
  })
}

resource "aws_iam_role" "external_dns" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.name}-role" })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
