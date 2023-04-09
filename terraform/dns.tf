// Provision a TLS certificate with HTTPS
data "aws_route53_zone" "public" {
  name         = local.domain_name // give your own domain name
  private_zone = false
}

resource "aws_acm_certificate" "tls_cert" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public.zone_id
}

// To check that your cert is provisioned, in case other resources depend on the cert
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.tls_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.api_validation : record.fqdn
  ]
}

// Maps the domain name of your load balancer to your domain name
resource "aws_route53_record" "a_record" {
  name    = aws_acm_certificate.tls_cert.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = false
  }
}