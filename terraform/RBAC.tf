# Setup RBAC for the entire webapp service plan and its slots

#Assigning Website contributor role to the service principal of the production slot
resource "azurerm_role_assignment" "nodejs_appservice_prod_contributor" {
  scope                = azurerm_service_plan.asp_appservice_lab.id
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.nodejs_appservice_prod.id
}

#Assigning Website contributor role to the service principal of the staging slot
resource "azurerm_role_assignment" "nodejs_appservice_staging_contributor" {
  scope                = azurerm_service_plan.asp_appservice_lab.id
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.nodejs_appservice_staging.id
}