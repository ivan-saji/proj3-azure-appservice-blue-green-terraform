#mention the app service here WebApp here

resource "azurerm_linux_web_app" "appservice_lab" {
  name                = "ivan-appservice-lab"
  location            = azurerm_resource_group.rg_appservice_lab.location
  resource_group_name = azurerm_resource_group.rg_appservice_lab.name
  service_plan_id     = azurerm_service_plan.asp_appservice_lab.id
  https_only           = true

  site_config {
    always_on = true

    #Setting the health check path to "/health" to monitor the health of the application. This is important for ensuring that the application is running correctly and can help with automatic recovery in case of failures.
    health_check_path = "/health"

    application_stack {
      node_version = "24-lts"
    }
  }
}

#Create deployment for Production

resource "azurerm_app_service_source_control" "production_source_control" {
  app_id                = azurerm_linux_web_app.appservice_lab.id
  branch                = "main"
  repo_url              = "https://github.com/ivan-saji/nodejs-docs-hello-world.git"

}