resource "azurerm_role_assignment" "nodejs_appservice_prod_contributor" {
  scope                = azurerm_linux_web_app.appservice_lab.id
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.nodejs_appservice_prod.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "nodejs_appservice_staging_contributor" {
  scope                = azurerm_linux_web_app.appservice_lab.id
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.nodejs_appservice_staging.object_id
  principal_type       = "ServicePrincipal"
}