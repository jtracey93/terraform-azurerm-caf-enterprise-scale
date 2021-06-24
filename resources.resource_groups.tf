resource "azurerm_resource_group" "enterprise_scale" {
  for_each = local.azurerm_resource_group_enterprise_scale

  provider = azurerm.management

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_resource_group" "enterprise_scale_connectivity" {
  for_each = local.azurerm_resource_group_enterprise_scale_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}
