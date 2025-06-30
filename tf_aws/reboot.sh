terraform destroy -auto-approve \
  -var-file=../tfvars/aws.tfvars \
  -var-file=../tfvars/terraform.tfvars \
  -var-file=../tfvars/terraform.tfvars.local
terraform plan -out=tfplan \
  -var-file=../tfvars/aws.tfvars \
  -var-file=../tfvars/terraform.tfvars \
  -var-file=../tfvars/terraform.tfvars.local
terraform apply -auto-approve tfplan