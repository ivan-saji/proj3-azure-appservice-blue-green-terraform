#This TF file creates app registration, service principal, Federated credential for the production slot

#Prod App Registration
resource "azuread_application" "nodejs_appservice_prod" {
  display_name = "nodejs-appservice-prod"
}

#Prod Service Principal
resource "azuread_service_principal" "nodejs_appservice_prod" {
  client_id = azuread_application.nodejs_appservice_prod.application_id
}

#Prod Federated Credential
resource "azuread_application_federated_identity_credential" "nodejs_appservice_prod" {
  application_id         = azuread_application.nodejs_appservice_prod.application_id
  display_name          = "nodejs-appservice-prod-federated-credential"
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "add our OIDC credential subject here"
  audiences             = ["api://AzureADTokenExchange"]
}