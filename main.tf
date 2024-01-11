terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 3.0.0"
  }
  backend "azurerm" {}
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

locals {
  address_spaces = yamldecode(file("${path.module}/vnet.yml"))["address_spaces"]
}

resource "azurerm_resource_group" "example" {
  name     = "rg-gatewaytest"
  location = "West Europe"
}

resource "azurerm_route_table" "example" {
  name                = "rg-gatewaysubnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_route" "example" {
  for_each = { for i, address_space in local.address_spaces : i => address_space }

  name                   = "spoke${each.key}"
  resource_group_name    = azurerm_resource_group.example.name
  route_table_name       = azurerm_route_table.example.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.0.1" # Azure Firewall IP
}
