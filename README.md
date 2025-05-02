# infoblox_iac
Various demos of using infrastructure as code to manage Infoblox 

## Terraform

If you have write access to vcenter (API isn't available in just ESXi) you can run `terraform apply` to spin up a NIOS instance

## Prep

Due to the size of the NIOS image this may take some time depending on network latency.
If you want to spin instances up and down, it's recommended you upload the instane to the datastore or use a template.

Firstly create a file called "terraform.tfvars"

** Make sure this filename is in the .gitignore file so it isn't added to the repo **

Inside that file populate the following:

NOTE: These can also be passed via the CLI if you don't wish to store them in a flat file.

```bash
vsphere_user = ""

vsphere_password = ""

vsphere_server = ""

v_datacenter = ""

v_datastore = ""

v_network = ""

vm_name = ""

v_resource_pool = ""

v_cpu_count =   //number

v_memory_count =  //number

v_os_guest_type = "" 

v_disk_size =  //number

v_host = ""

vm_template_name = ""
```

**TODO** Need to look at how best to deploy the OVA file 