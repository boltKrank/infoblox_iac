set -x 

# Example usage: 
# ./add_offline_member.sh admin Infoblox@312 52.65.222.236 10.32.2.20 10.32.2.1 member01.localdomain 

USERNAME=$1
PASSWORD=$2
MASTER_IP=$3
MEMBER_IP=$4
GATEWAY_IP=$5
MEMBER_FQDN=$6

curl -k -u $USERNAME:$PASSWORD -H "content-type: application/json" \
-X POST "https://$MASTER_IP/wapi/v2.12/member?_return_as_object=1" \
-d "{\"config_addr_type\": \"IPV4\", \
     \"platform\":\"VNIOS\", \
     \"host_name\":\"$MEMBER_FQDN\", \
     \"vip_setting\": {\"subnet_mask\":\"255.255.255.0\", \
                     \"address\":\"$MEMBER_IP\", \
                     \"gateway\":\"$GATEWAY_IP\"}}"

 # >> Output =>  awk -F'member/|:member01' '{print $2}' => reference ID
 #
 # Next step
 # 
