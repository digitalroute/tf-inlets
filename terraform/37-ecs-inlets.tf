data "template_file" "ecs_inlets" {
  template = "${file("templates/ecs_task_definition_inlets.tpl.json")}"

  vars {
    AWS_REGION       = "${data.aws_region.current.name}"
    AWSLOGS_GROUP    = "${local.cw_log_group}"
    INL_TOKEN_SECRET = "${aws_secretsmanager_secret_version.inlets_token.arn}"
  }
}

resource "aws_ecs_task_definition" "ecs_inlets" {
  family                = "${var.project}-task"
  container_definitions = "${data.template_file.ecs_inlets.rendered}"
  execution_role_arn    = "${aws_iam_role.ecs_inlets.arn}"
}

resource "aws_ecs_service" "ecs_inlets" {
  name = "${var.project}-service"

  cluster                            = "${aws_ecs_cluster.ecs_inlets.name}"
  task_definition                    = "${aws_ecs_task_definition.ecs_inlets.arn}"
  desired_count                      = "1"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300

  //iam_role = "${aws_iam_role.ecs_inlets.arn}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.inlets.arn}"
    container_name   = "inlets"
    container_port   = 8080
  }
}

resource "aws_iam_role" "ecs_inlets" {
  name               = "${var.project}-ecs"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_inlets.json}"
}

data "aws_iam_policy_document" "ecs_inlets" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_inlets_ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecs_inlets.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "inlets_token" {
  role       = "${aws_iam_role.ecs_inlets.name}"
  policy_arn = "${aws_iam_policy.inlets_token.arn}"
}
