module "bootstrap" {
  source = "../../modules/aws/bootstrap"

  name_context = local.name_context

}
