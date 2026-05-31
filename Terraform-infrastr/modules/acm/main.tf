resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.san_names
  tags                      = var.tags
}

resource "aws_route53_record" "validation" {
  count = var.route53_zone_id != "" ? length(aws_acm_certificate.this.domain_validation_options) : 0

  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.this.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.this.domain_validation_options[count.index].resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.this.domain_validation_options[count.index].resource_record_value]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.route53_zone_id != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = aws_route53_record.validation[*].fqdn
}
