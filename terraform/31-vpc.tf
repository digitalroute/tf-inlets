data "aws_availability_zones" "available" {}

locals {
  number_of_zones = "${length(data.aws_availability_zones.available.names)}"
  prefix_subnet   = "10.0"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${local.prefix_subnet}.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    "Name" = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    "Name" = "${var.project}-igw"
  }
}

resource "aws_subnet" "inlets" {
  count = "${local.number_of_zones}"

  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${local.prefix_subnet}.${count.index*8}.0/21"

  tags {
    "Name" = "${var.project}-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "inlets" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    "Name" = "${var.project}-inlets"
  }
}

resource "aws_route_table_association" "inlets" {
  count = "${local.number_of_zones}"

  subnet_id      = "${aws_subnet.inlets.*.id[count.index]}"
  route_table_id = "${aws_route_table.inlets.id}"
}
