# Destrot the current state
terraform destroy -auto-approve |ts

# Recreate the state
terraform plan 
terraform apply -auto-approve |ts

