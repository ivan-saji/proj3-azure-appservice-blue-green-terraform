#This TF file creates app registration, service principal, Federated credential for the staging slot

#Staging App Registration
resource "azuread_application" "nodejs_appservice_staging" {
  display_name = "nodejs-appservice-staging"
}

#Staging Service Principal
resource "azuread_service_principal" "nodejs_appservice_staging" {
  client_id = azuread_application.nodejs_appservice_staging.client_id
}

#Staging Federated Credential
resource "azuread_application_federated_identity_credential" "nodejs_appservice_staging" {
  application_id = azuread_application.nodejs_appservice_staging.id
  display_name   = "nodejs-appservice-staging-federated-credential"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:ivan-saji@283069219/nodejs-docs-hello-world@1324792684:ref:refs/heads/staging"
  audiences      = ["api://AzureADTokenExchange"]
}