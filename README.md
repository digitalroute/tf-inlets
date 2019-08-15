# tf-inlets

Terraform your own inlets

## Build your own docker image

## Terraform

If you would like to set up your own inlets server on AWS you can use this repository as a terraform module.

Requirements:

* Route53 zone, this needs to be an empty zone, for example a delegated subdomain of your main domain.
* ssh key for the AWS EC2 instance(s)

The zone can be set up like this, note the output which you can use to delegate the zone from your main DNS (example.com):

```terraform
resource "aws_route53_zone" "zone" {
  name = "inlets.example.com"

  provider = "aws.example"
}

output "zone_name_servers" {
  value = "${aws_route53_zone.zone.name_servers}"
}
```

An ssh key can be added like this:

```terraform
resource "aws_key_pair" "ssh_key" {
  key_name   = "inlets-ssh-key"
  public_key = "ssh-rsa lotsofdatahere noreply@example.com"

  provider = "aws.example"
}
```

And here is how to use the actual inlets module:

```terraform
module "inlets" {
  source = "git::git@github.com:digitalroute/tf-inlets.git//terraform"

  project           = "example-inlets"
  ecs_instance_type = "t3.small"
  dns_zone_id       = "${aws_route53_zone.zone.id}"
  dns_zone_name     = "${aws_route53_zone.zone.name}"
  ssh_key_name      = "${aws_key_pair.ssh_key.key_name}"
  allow_cidr_blocks = ["0.0.0.0/0"]

  providers = {
    aws = "aws.example"
  }
}
```
