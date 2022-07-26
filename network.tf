
locals {
  vpc_config_temp = {
    vpc_id             = var.vpc_id
    subnets            = toset(var.subnets)
    security_group_ids = var.security_group_ids
  }

  vpc_config = var.vpc_id != "" && length(var.subnets) != 0 && length(var.security_group_ids) != 0 ? [local.vpc_config_temp] : []


}
