output "GM_PUBLIC_IP" {
  value = azurerm_linux_virtual_machine.nios-grid-master.public_ip_address
}