locals {
  cw_log_group = "/ecs/${var.project}"
}

resource "aws_cloudwatch_log_group" "ecs_inlets" {
  name = "${local.cw_log_group}"
}
