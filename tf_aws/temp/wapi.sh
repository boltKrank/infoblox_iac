GM_IP=$1
OBJECT_TYPE=$2
curl -k -u admin:Infoblox@312 https://$GM_IP/wapi/v2.10/$OBJECT_TYPE

