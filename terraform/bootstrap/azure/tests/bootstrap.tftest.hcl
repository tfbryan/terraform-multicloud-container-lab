mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/tfstate/providers/Microsoft.Storage/storageAccounts/tfstate12345"
    }
  }

  mock_resource "azurerm_storage_container" {
    defaults = {
      id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/tfstate/providers/Microsoft.Storage/storageAccounts/tfstate12345/blobServices/default/containers/tfstate"
    }
  }

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/tfstate/providers/Microsoft.ManagedIdentity/userAssignedIdentities/github"
      principal_id = "12345678-1234-9876-4563-123456789012"
    }
  }
}
mock_provider "random" {}

run "github_state_access" {
  command = apply

  module {
    source = "../../modules/azure/bootstrap"
  }

  variables {
    name_context = {
      cloud       = { name = "azure", code = "az" }
      account     = { id = "subscription-id", code = "1234" }
      project     = { name = "multicloud", code = "mc" }
      environment = { name = "lab", code = "lab", id = "0" }
      region      = { name = "eastus", code = "ue1", id = "1" }
    }
    github_owner = "example"
    github_repo  = "infrastructure"
    tags         = {}
  }

  assert {
    condition     = azurerm_federated_identity_credential.github.subject == "repo:example/infrastructure:environment:lab"
    error_message = "The federation must trust only the intended repository and environment."
  }

  assert {
    condition     = azurerm_federated_identity_credential.github.issuer == "https://token.actions.githubusercontent.com" && azurerm_federated_identity_credential.github.audience == tolist(["api://AzureADTokenExchange"])
    error_message = "The federation must use the GitHub issuer and Azure token-exchange audience."
  }

  assert {
    condition     = azurerm_federated_identity_credential.github.user_assigned_identity_id == azurerm_user_assigned_identity.github.id
    error_message = "The federation must belong to the GitHub managed identity."
  }

  assert {
    condition     = azurerm_role_assignment.github_tfstate.scope == azurerm_storage_container.tfstate.id && azurerm_role_assignment.github_tfstate.principal_id == azurerm_user_assigned_identity.github.principal_id && azurerm_role_assignment.github_tfstate.role_definition_name == "Storage Blob Data Contributor"
    error_message = "The managed identity must have blob access scoped to the state container."
  }
}
