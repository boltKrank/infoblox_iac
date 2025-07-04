username=$1
password=$2
GRID_MASTER_IP=$3

curl -k -u $username:$password -X POST \
  "https://$GRID_MASTER_IP/wapi/v2.10/grid?_function=generate_token" \
  -H "Content-Type: application/json"
