set -x

username=$1
password=$2
GM_IP=$3
WAPI_VERSION=$4


curl -k -u "$username:$password" -H "Content-Type: application/json" -X POST \
"https://$GM_IP/wapi/$WAPI_VERSION/member" \
-d '{
  "host_name": "gm.localdomain",
  "vip_setting": {
    "address": "10.32.1.6",
    "subnet_mask": "255.255.255.0",
    "gateway": "10.32.1.1"
  },
  "platform": "VNIOS",
  "config_addr_type": "IPV4"
}'
