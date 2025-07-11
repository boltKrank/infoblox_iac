# curl -sk https://${aws_instance.grid_master.public_ip}/infoblox.crt -o ./grid_master.crt
url="$1"
echo "curl -sk https://$url/infoblox.crt -o ./grid_master.crt"
# curl -sk https://$url/infoblox.crt -o ./grid_master.crt
curl -sk https://$url/infoblox.crt

