#Mention the app service plan here

resource "azurerm_service_plan" "asp_appservice_lab" {
  name                = "asp-appservice-lab"
  location            = azurerm_resource_group.rg_appservice_lab.location
  resource_group_name = azurerm_resource_group.rg_appservice_lab.name
  os_type             = "Linux"
  sku_name            = "S1"
}
