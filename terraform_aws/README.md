# Terraform AWS

## Install AWS CLI

```bash
aws configure
```

## Find the NIOS marketplace AMI ID

```bash
#!/bin/zsh
aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=*Infoblox NIOS*" --region ap-southeast-2 --query 'Images[*].[ImageId,Name]' --output table
```

Or specifically NIOS 9.0.5(BYOL):

```bash
#!/bin/zsh
aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=*Infoblox NIOS 9.0.5(BYOL)*" --region ap-southeast-2 --query 'Images[*].[ImageId,Name]' --output table
```

## Code for generating keys (if not using an existing key)

```Terraform
resource "tls_private_key" "nios_terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-generated-key"
  public_key = tls_private_key.nios_terraform_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.nios_terraform_key.private_key_pem
  filename = "${path.module}/my-generated-key.pem"
  file_permission = "0600"
}
```

To check which keys are already there:

```bash
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output table
```


AWS Naming Examples:


● EC2: username-nios-test-useast -ec2 -1

● KeyPair: username -nios-test-useast -keypair -1

● VPC: username -nios-test-useast -vpc -1

● Subnet: username -nios-test-useast -subnet -1

● RouteTable: username-nios-test-useast -rt -1

● SecurityGroup: username -nios-test-useast -nsg -1

● NetworkInterface: username -nios-test-useast -nic -1

● Elastic IP: username -nios-test-useast -eip -1

● S3: username-nios-test-useast -s3 -