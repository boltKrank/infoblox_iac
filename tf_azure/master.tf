# NICs x 2

resource "azurerm_network_interface" "mgmt_nic" {
  name = "mgmt_nic"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # This is needed to allow a smooth destruction later
  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
    ignore_changes = []
  }
  # depends_on = [ azurerm_linux_virtual_machine.nios-grid-master ]

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.mgmt_subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address = var.mgmt_nic_private_ip
  }
}

resource "azurerm_network_interface" "lan1_nic" {
  name = "lan1_nic"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # This is needed to allow a smooth destruction later
  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
    ignore_changes = []
  }
  # depends_on = [ azurerm_linux_virtual_machine.nios-grid-master ]

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.lan1_subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address = var.lan1_nic_private_ip
    public_ip_address_id = azurerm_public_ip.lan1_pip.id
  }

}


resource "azurerm_public_ip" "lan1_pip" {
  name                = "gm-lan1-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  depends_on = [ azurerm_network_interface.lan1_nic ]
}

resource "azurerm_linux_virtual_machine" "nios-grid-master" {
  name = "grid-master-vm"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_F2"
  # This has to be same as the username for the SSH key !!!
  admin_username = "azureuser"

  network_interface_ids = [azurerm_network_interface.mgmt_nic.id,
                           azurerm_network_interface.lan1_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.public_key
  }


  custom_data = base64encode(<<EOF
#infoblox-config
remote_console_enabled: y
default_admin_password: ${var.default_admin_password}
temp_license: enterprise dns dhcp cloud nios IB-V825
EOF
  )


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 500

  }


  source_image_reference {
    publisher = var.image_publisher_name
    offer     = var.image_offer_name
    sku       = var.image_sku_name
    version   = var.image_version
  } 

    plan {
        name = var.image_sku_name
        product = var.image_offer_name
        publisher = var.image_publisher_name
      
    }



}   