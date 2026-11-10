output "github_client_id" {
  description = "Client ID of the GitHub Actions managed identity"
  value       = azurerm_user_assigned_identity.github.client_id
}

output "state_storage_account_name" {
  description = "Storage account containing the platform state"
  value       = azurerm_storage_account.tfstate.name
}

output "state_container_name" {
  description = "Blob container containing the platform state"
  value       = azurerm_storage_container.tfstate.name
}
