resource "aws_security_group" "inlets_lb" {
  name        = "${var.project}-lb"
  description = "Allow HTTPS to inlets server"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "${var.project}-lb"
  }
}

resource "aws_lb" "inlets" {
  name               = "${var.project}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.inlets_lb.id}"]
  subnets            = ["${aws_subnet.inlets.*.id}"]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "inlets" {
  name     = "${var.project}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    path     = "/tunnel"
    protocol = "HTTP"
  }

  depends_on = [
    "aws_lb.inlets",
  ]
}

resource "aws_lb_listener" "inlets_https" {
  load_balancer_arn = "${aws_lb.inlets.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.certificate.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.inlets.arn}"
  }
}
