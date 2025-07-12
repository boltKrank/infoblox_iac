resource "azurerm_network_security_group" "custom_nsg" {
  name                = "custom-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # Ingress TCP
  security_rule {
    name                       = "AllowTCP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "4434", "8787"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Ingress UDP
  security_rule {
    name                       = "AllowUDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "1194", "2114"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Egress: Allow all
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
