#Create a slot for staging environment

resource "azurerm_linux_web_app_slot" "staging_slot" {
  name                = "ivan-appservice-lab-staging"
  app_service_id     = azurerm_linux_web_app.appservice_lab.id

  site_config {
    #setting always on to false as it is non-prod and we want to save cost. In production slot, we will set it to true.
    always_on = false
    health_check_path = "/health"

    application_stack {
      node_version = "24-lts"
    }
  }
}

# AzureRM's azurerm_app_service_source_control resource
# does not support configuring source control directly for slots.
# Staging deployment is handled through GitHub Actions instead.