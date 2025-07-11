USERNAME=$1
PASSWORD=$2
GM_IP=$3
HOSTNAME=$4

curl -k -u $USERNAME:$PASSWORD -H "Content-Type: application/json" \
  -X POST "https://$GM_IP/wapi/v2.11/member" \
-d "{ \
  \"host_name\": "$HOSTNAME", \  
  \`"vip_setting\": { \
    \"address\": \"10.32.2.20\", \      
    \"subnet_mask\": \"255.255.255.0\", \
    \"gateway\": \"10.32.2.1\" \
  }, \
  \"platform\": \"VNIOS\", \
  \"config_addr_type\": \"IPV4\" \
}" 



