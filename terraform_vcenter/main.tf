# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl  = true
  api_timeout          = 10
}

data "vsphere_datacenter" "datacenter" {
  name = var.v_datacenter
}

data "vsphere_host" "host" {
    datacenter_id = data.vsphere_datacenter.datacenter.id
    name = var.v_host
}

data "vsphere_datastore" "datastore" {
  name          = var.v_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#VM Network
data "vsphere_network" "network" {
  name          = var.v_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "vm_template_name" {
  name = "/${var.v_datacenter}/vm/${var.vm_template_name}"
  
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus         = var.v_cpu_count
  memory           = var.v_memory_count
  guest_id         = var.v_os_guest_type
  
  #MGMT
  network_interface {
    network_id = data.vsphere_network.network.id
  } 

  #LAN1
  network_interface {
    network_id = data.vsphere_network.network.id
  } 

  #HA
  network_interface {
    network_id = data.vsphere_network.network.id
  } 

  #LAN2
  network_interface {
    network_id = data.vsphere_network.network.id
  } 
  
  #Disable network waits (workaround at the moment)
  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1


  clone {
    template_uuid = data.vsphere_virtual_machine.vm_template_name.id    
  }
  
  disk {
    label = "disk0"
    size  = var.v_disk_size #Must be minimum for NIOS 150Gb or 500Gb
    thin_provisioned = true #Speeds things up and saves space if this is a temp deploy
  }

}
