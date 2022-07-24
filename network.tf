data "aws_vpc" "supplied_vpc" {
  count = var.vpc_custom != "" ? 1 : 0
  id    = var.vpc_custom
}

data "aws_vpc" "default_vpc" {
  count   = var.vpc_custom == "" ? 1 : 0
  default = true
}

locals {
  vpc = var.vpc_custom != "" ? data.aws_vpc.supplied_vpc[0] : data.aws_vpc.default_vpc[0]
}

data "aws_subnets" "subnets" {
  tags = {
    Type = "Public"
  }
}

data "aws_security_group" "public_default_sg" {
  count  = var.security_group_id == "" ? 1 : 0
  vpc_id = local.vpc.id
  name   = "default"
}

locals {
  sg = var.security_group_id != "" ? var.security_group_id : data.aws_security_group.public_default_sg[0].id
}
