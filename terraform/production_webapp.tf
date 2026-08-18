#mention the app service here WebApp here

resource "azurerm_linux_web_app" "appservice_lab" {
  name                = "ivan-appservice-lab"
  location            = azurerm_resource_group.rg_appservice_lab.location
  resource_group_name = azurerm_resource_group.rg_appservice_lab.name
  service_plan_id     = azurerm_service_plan.asp_appservice_lab.id
  https_only          = true

  # This performs the build first then deploys the application to the web app. This is important for ensuring that the application is built correctly and can be deployed without errors.
  
  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }
  site_config {
    always_on = true

    #Setting the health check path to "/health" to monitor the health of the application. This is important for ensuring that the application is running correctly and can help with automatic recovery in case of failures.
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5

    application_stack {
      node_version = "24-lts"
    }
  }
}

#Create deployment for Production
#Deployment is handled through GitHub Actions instead of using azurerm_app_service_source_control resource, as it does not support configuring source control directly for slots.
