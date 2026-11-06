module "bootstrap" {
  source = "../../modules/azure/bootstrap"

  name_context = local.name_context

  tags = local.tags
}
