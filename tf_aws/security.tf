/*
From the documentation:

Link: https://docs.infoblox.com/space/NAIG/37650793/Provisioning+vNIOS+for+AWS+Using+the+BYOL+Model


Use the following points and take appropriate action for creating new inbound rules:

Permit SSH traffic (TCP/22) from the preferred prefix.
Open the port for DNS (UDP/53).
Permit secure web traffic (HTTPS/443) only from a Custom IP prefix representing the network of hosts that access the vNIOS instance for management and configuration.
Open two ports for NIOS Grid Joining traffic:
UDP/1194
UDP/2114
Open the port for the Infoblox API Proxy (TCP/8787).
Open a port for VM VRRP (UDP/802) if the node is a member in an HA pair.
Open the following ports if you want to deploy the reporting appliance IB-V5005 that is supported in NIOS 8.6.2 and later versions:
7000 WebUI (Master,Indexer)
7089 Management
7887 Replication
9997 Data Forwarding
8000 WebUI
8089 Management
9185 Splunk REST API
Configure a minimum of six rules based on the list above.




*/


# 3. Security Group (allow SSH + HTTP out)
resource "aws_security_group" "nios_security_group" {
  name = "nios_security_group_test"
  vpc_id = aws_vpc.nios_vpc.id


  ingress {
    # Allow SSH from a specific IP address (replace with your IP)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # Allow DNS traffic
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    #HTTPS
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    # NIOS Grid Joining traffic
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2114
    to_port     = 2114
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {

    # Infoblox API Proxy
    from_port   = 8787
    to_port     = 8787
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

