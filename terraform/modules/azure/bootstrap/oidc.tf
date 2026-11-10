resource "azurerm_federated_identity_credential" "github" {
  name                      = "github-actions"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_owner}/${var.github_repo}:environment:${var.name_context.environment.code}"
}
