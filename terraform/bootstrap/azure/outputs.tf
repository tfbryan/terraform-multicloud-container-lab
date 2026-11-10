output "github_client_id" {
  description = "Client ID of the GitHub Actions managed identity"
  value       = module.bootstrap.github_client_id
}

output "tenant_id" {
  description = "Microsoft Entra tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}

output "state_storage_account_name" {
  description = "Storage account containing the platform state"
  value       = module.bootstrap.state_storage_account_name
}

output "state_container_name" {
  description = "Blob container containing the platform state"
  value       = module.bootstrap.state_container_name
}
