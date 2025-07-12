# Virtual network

resource "azurerm_virtual_network" "vnet" {
  name                = "infoblox-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet x 2 (MGMT) + (LAN1)


resource "azurerm_subnet" "mgmt_subnet" {
  name                 = "nios-mgmt-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.mgmt_subnet_cidr
}

resource "azurerm_subnet" "lan1_subnet" {
  name                 = "nios-lan1-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.lan1_subnet_cidr
}



# Security Group:  TCP: 22,443,8787; UDP: 53, 1194,2114 (in security.tf) 
