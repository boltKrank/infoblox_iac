# Terraform NIOS Azure

## References

https://github.com/r2rajan/Infoblox-Terraform-Azure

## Azure CLI

Install Azure CLI 

Latest info available at: https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build

To login to Azure, run `az login` and you'll be redirected to a broswer where you can use SSO to login.

### Azure Service Principal

This is a service user, so all commands/calls for this will be done through this user.

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/08027151-6171-48b1-9475-09a8c5389f3a"

### Environment variables


```bash
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"
```