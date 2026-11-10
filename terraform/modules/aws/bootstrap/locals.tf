locals {
  env = var.name_context.environment.code

  github_subjects = "repo:${var.github_owner}/${var.github_repo}:environment:${local.env}"

  state_key_prefix = "${var.name_context.project.code}/${var.name_context.environment.code}/${var.name_context.cloud.name}"
  state_key        = "${local.state_key_prefix}/platform.tfstate"
  state_lock_key   = "${local.state_key}.tflock"
}
