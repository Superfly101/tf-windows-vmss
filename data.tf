data "azurerm_image" "custom" {
  name                = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
