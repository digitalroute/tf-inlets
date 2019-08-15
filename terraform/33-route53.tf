resource "aws_route53_record" "inlets_lb" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.inlets.dns_name}"
    zone_id                = "${aws_lb.inlets.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "inlets_lb_wildcard" {
  zone_id = "${var.dns_zone_id}"
  name    = "*.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.inlets.dns_name}"
    zone_id                = "${aws_lb.inlets.zone_id}"
    evaluate_target_health = true
  }
}
