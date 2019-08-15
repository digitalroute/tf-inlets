resource "aws_ecs_cluster" "ecs_inlets" {
  name = "${var.project}"
}

data "aws_ami" "ecs_inlets_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "template_file" "ecs_inlets_instance_userdata" {
  template = "${file("${path.module}/templates/ecs_userdata.tpl.sh")}"

  vars {
    ECS_CLUSTER_NAME = "${aws_ecs_cluster.ecs_inlets.name}"
  }
}

resource "aws_iam_role" "ecs_ec2" {
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_ec2" {
  role = "${aws_iam_role.ecs_ec2.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_inlets_ec2_role" {
  role       = "${aws_iam_role.ecs_ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_inlets_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_launch_configuration" "ecs_inlets_launch_configuration" {
  name_prefix          = "${var.project}-ecs-"
  image_id             = "${data.aws_ami.ecs_inlets_ami.id}"
  instance_type        = "${var.ecs_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_ec2.name}"

  associate_public_ip_address = true
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.ecs_inlets.id}",
  ]

  ebs_block_device {
    device_name           = "/dev/xvdcz"
    volume_size           = "30"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = "${data.template_file.ecs_inlets_instance_userdata.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_inlets_autoscaling" {
  name                 = "${var.project}-ecs"
  vpc_zone_identifier  = ["${aws_subnet.inlets.*.id}"]
  min_size             = "1"
  desired_capacity     = "1"
  max_size             = "2"
  launch_configuration = "${aws_launch_configuration.ecs_inlets_launch_configuration.name}"

  lifecycle {
    create_before_destroy = true
  }

  tags = [{
    key                 = "Name"
    value               = "${var.project}-ecs-autoscaling"
    propagate_at_launch = true
  }]
}

resource "aws_security_group" "ecs_inlets" {
  name        = "${var.project}-ecs"
  description = "ECS inlets server"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.inlets_lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "${var.project}-ecs"
  }
}
