locals {
  environment = var.environment_list[var.environment]
  region      = var.aws_region.primary

  account = {
    id   = data.aws_caller_identity.current.account_id
    code = substr(data.aws_caller_identity.current.account_id, -4, 4)
  }

  name_context = {
    cloud       = var.cloud
    account     = local.account
    project     = var.project
    environment = local.environment
    region      = local.region
  }

  cloud_tags = {
    environment = local.environment.name
    project     = var.project.name
  }

  custom_tags = merge(
    var.common_tags,
    local.cloud_tags
  )

  tags = {
    for key, value in local.custom_tags :
    "${var.tag_prefix}-${key}" => value
  }
}
