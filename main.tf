
terraform {
  required_providers {
    azurerm = "=2.41.0"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-management" {
  name = "rg-management"
  location = "Norway East"
}

resource "azurerm_resource_group" "rg-playground" {
  name = "rg-playground"
  location = "Norway East"
}

resource "azurerm_virtual_network" "vnet-management-1" {
  name = "vnet-management-1"
  location = azurerm_resource_group.rg-management.location
  resource_group_name = azurerm_resource_group.rg-management.name

  address_space = ["10.1.0.0/16"]

  subnet {
    name = "vnet-management-1-snet-gw"
    address_prefix = "10.1.0.0/24"
  }

  subnet {
    name = "vnet-management-1-snet-servers"
    address_prefix = "10.1.16.0/20"
  }
}

resource "azurerm_virtual_network" "vnet-playground-1" {
  name = "vnet-playground-1"
  location = azurerm_resource_group.rg-playground.location
  resource_group_name = azurerm_resource_group.rg-playground.name

  address_space = ["10.2.0.0/16"]

  subnet {
    name = "vnet-std-1-snet-gw"
    address_prefix = "10.2.0.0/24"
  }

  subnet {
    name = "vnet-std-1-snet-servers"
    address_prefix = "10.2.16.0/20"
  }
}

resource "azurerm_virtual_network_peering" "standard-to-management" {
  name = "standard-to-mgmt-peering"
  resource_group_name = azurerm_resource_group.rg-playground.name
  virtual_network_name = azurerm_virtual_network.vnet-playground-1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-management-1.id
}

resource "azurerm_virtual_network_peering" "management-to-standard" {
  name = "standard-to-mgmt-peering"
  resource_group_name = azurerm_resource_group.rg-management.name
  virtual_network_name = azurerm_virtual_network.vnet-management-1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-playground-1.id
}
