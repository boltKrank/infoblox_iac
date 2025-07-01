### user_data options

✅ Full List of Known user_data Options for Infoblox NIOS (Grid Master)
Option	Description
grid_name	Name of the grid to create (required).
grid_shared_secret	Shared secret for secure member joins (required).
set_grid_master	true to designate this node as Grid Master (required for master).
default_admin_password	Sets the default admin password.
temp_license	Enables temporary licenses. Can list multiple (e.g. dns dhcp nios).
remote_console_enabled	y to allow SSH access.
host_name	Sets the hostname of the appliance.
timezone	Sets the timezone (e.g. Australia/Sydney, UTC).
ntp_enable	true to enable NTP.
ntp_servers	Comma-separated list of NTP server IPs or FQDNs.
dns_servers	Comma-separated list of DNS server IPs.
domain_name	Domain suffix to assign (e.g. example.com).
syslog_servers	Comma-separated list of syslog destinations (IP:port).
snmp_enable	true to enable SNMP.
snmp_community	SNMP community string (e.g. public).
upgrade_image_url	Optional URL to download and install an NIOS upgrade image at first boot.
license_file_url	URL to fetch a license file to apply (for permanent licensing).
🧪 Experimental / Rare Fields (Use with Caution)
Option	Notes
vip	Sets the VIP for HA deployments (normally configured after boot).
lan2_enable	Enables LAN2 port (true/false).
ha_enable	Enables high availability if a secondary node is booted together (not usually used in cloud).

⚠️ Note: Not all AMIs or NIOS versions may support every field above — use release notes to confirm.

#### Example

#infoblox-config
grid_name: "demogrid"
grid_shared_secret: "test"
set_grid_master: true
default_admin_password: "Infoblox@312"
temp_license: dns dhcp nios vnios enterprise
remote_console_enabled: y
host_name: "nios-master"
timezone: "UTC"
ntp_enable: true
ntp_servers: "0.pool.ntp.org,1.pool.ntp.org"
dns_servers: "8.8.8.8,1.1.1.1"
domain_name: "infra.example.com"
syslog_servers: "10.0.0.50:514"
snmp_enable: true
snmp_community: "public"