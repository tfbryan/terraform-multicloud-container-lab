provider "aws" {
  region = var.aws_region.primary.name

  default_tags {
    tags = local.tags
  }
}
