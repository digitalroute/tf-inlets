resource "aws_acm_certificate" "certificate" {
  domain_name               = "${var.dns_zone_name}"
  subject_alternative_names = ["*.${var.dns_zone_name}"]
  validation_method         = "DNS"

  tags {
    "Name" = "${var.project}-certificate"
  }
}

resource "aws_route53_record" "certificate" {
  name    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.dns_zone_id}"
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.certificate.fqdn}"]
}

output "certificate_arn" {
  value = "${aws_acm_certificate_validation.certificate.certificate_arn}"
}
