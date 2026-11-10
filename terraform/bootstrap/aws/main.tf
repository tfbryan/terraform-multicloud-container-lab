module "bootstrap" {
  source = "../../modules/aws/bootstrap"

  name_context = local.name_context
  github_owner = var.github_owner
  github_repo  = var.github_repo

}
