#Mention the app service plan here

resource "azurerm_service_plan" "asp_appservice_lab" {
  name                = "asp-appservice-lab"
  location            = azurerm_resource_group.rg_appservice_lab.location
  resource_group_name = azurerm_resource_group.rg_appservice_lab.name
  os_type             = "Linux"
  sku_name            = "F1"
}

#mention the app service here WebApp here

resource "azurerm_linux_web_app" "appservice_lab" {
  name                = "ivan-appservice-lab"
  location            = azurerm_resource_group.rg_appservice_lab.location
  resource_group_name = azurerm_resource_group.rg_appservice_lab.name
  service_plan_id     = azurerm_service_plan.asp_appservice_lab.id
  https_only           = true

  site_config {
    always_on = false
  }
}

#Create deployment for Production

resource "azurerm_app_source_control" "production_source_control" {
  app_id                = azurerm_linux_web_app.appservice_lab.id
  branch                = "main"
  repo_url              = "https://github.com/ivan-saji/nodejs-docs-hello-world.git"
}
