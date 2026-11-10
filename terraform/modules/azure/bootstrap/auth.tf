module "azure_github_identity_name" {
  source = "../../common/naming"

  name_context = var.name_context
  type         = "identity"
  descriptor   = "cicd"
}

resource "azurerm_user_assigned_identity" "github" {
  name                = module.azure_github_identity_name.resource_name
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "github_tfstate" {
  scope                = azurerm_storage_container.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
