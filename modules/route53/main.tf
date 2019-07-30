/* ========================================================================= */
/* ================= HOSTNAME ============================================== */
/* ========================================================================= */

/* =============================================================== variables */

variable "app_name"    {}
variable "environment" {}
variable "base_domain" {}

/* ============================================= get base domain information */

data "aws_route53_zone" "external" {
  name = "${var.base_domain}"
}

data "aws_acm_certificate" "app-ssl" {
  provider = "aws.certificate"
  domain   = "*.${var.base_domain}"
  statuses = ["ISSUED"]
}

/* ================================================= apply the new subdomain */

resource "aws_api_gateway_domain_name" "app" {
  certificate_arn = "${data.aws_acm_certificate.app-ssl.arn}"
  domain_name     = "${var.app_name}-${var.environment}.${var.base_domain}"
}

resource "aws_route53_record" "app" {
  name    = "${aws_api_gateway_domain_name.app.domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.external.id}"
  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.app.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.app.cloudfront_zone_id}"
  }
}

/* ======================================================= final domain name */

output "name"        { value = "${aws_route53_record.app.name}" }
output "domain_name" { value = "${aws_api_gateway_domain_name.app.domain_name}" }
