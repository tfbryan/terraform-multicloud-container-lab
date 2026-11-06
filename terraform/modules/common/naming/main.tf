resource "random_string" "suffix" {
  count = local.random_suffix_enabled ? 1 : 0

  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}
