#Mention the resource group here

resource "azurerm_resource_group" "rg_appservice_lab" {
  name     = "rg-appservice-lab"
  location = "central india"
}
