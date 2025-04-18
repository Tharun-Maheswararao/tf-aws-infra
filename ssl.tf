# Data source to reference the imported certificate for demo environment
data "aws_acm_certificate" "imported_cert" {
  count       = var.aws_profile == "demo" ? 1 : 0
  domain      = var.profile_domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# Request an SSL certificate from AWS Certificate Manager for dev environment
resource "aws_acm_certificate" "dev_cert" {
  count             = var.aws_profile == "a4githubactions" ? 1 : 0
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name        = "dev-ssl-certificate"
    Environment = var.aws_profile
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records for dev environment
resource "aws_route53_record" "validation" {
  for_each = var.aws_profile == "a4githubactions" ? {
    for dvo in aws_acm_certificate.dev_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.profile_hosted_zone_id
}

# Certificate validation for dev environment
resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.aws_profile == "a4githubactions" ? 1 : 0
  certificate_arn         = aws_acm_certificate.dev_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}