export TF_LOG=debug
terraform plan 
terraform apply -auto-approve |ts
unset TF_LOG

