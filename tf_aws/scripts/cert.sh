set -x
USERNAME=$1
PASSWORD=$2
GRID_MASTER_IP=$3
GM_HOSTNAME=$4
WAPI_VERSION=$5

# Syntax: POST https://$GRID_MASTER_IP/wapi/$WAPI_VERSION/<object>?_function=<function_name>

curl -k -u $USERNAME:$PASSWORD -H "Content-Type: application/json" -X POST \
  "https://$GRID_MASTER_IP/wapi/v2.13.6/grid?_function=generate_certificate" \
  <<EOF 
  -d '{
    "certificate_usage": "admin",
    "member":"13.237.189.213"
  }'
  EOF


# curl -k -u $USERNAME:$PASSWORD -H "Content-Type: application/json" -X POST \
#   "https://$GRID_MASTER_IP/wapi/v2.13.6/grid?_function=generate_certificate" \
#   <<EOF 
#   -d '{
#     "certificate_usage": "ADMIN",
#     "member":"$GM_HOSTNAME"
#   }'
#   EOF


