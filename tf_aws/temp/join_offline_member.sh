set -x

USERNAME=$1
PASSWORD=$2
GM_IP=$3
MEMBER_REF=$4

curl -k -u $USERNAME:$PASSWORD \
  -H "Content-Type: application/json" \
  -X PUT "https://$GM_IP/wapi/v2.11/$MEMBER_REF" \
  -d "{}"

curl -k -u $USERNAME:$PASSWORD \
  -H "Content-Type: application/json" \
  -X PUT "https://$GM_IP/wapi/v2.11/$MEMBER_REF?_function=create_token" \
  -d "{}"

curl -k -u admin:Infoblox@312 -H "content-type: application/json" \
     -X POST "https://$GM_IP/wapi/v2.12/grid?_function=join&_return_as_object=1" \
     -d "{\"grid_name\":\"Infoblox\",\"master\":\"10.32.2.10\",\"shared_secret\":\"test\"}"
  



# REF=$1
# curl -k -u admin:Infoblox@312 -H "Content-Type: application/json" -X PUT "https://3.106.24.131/wapi/v2.11/member/b25lLnZpcnR1YWxfbm9kZSQx:member01.localdomain" -d "{\"pre_provisioning\":{\"licenses\":[\"dns\",\"dhcp\",\"enterprise\",\"nios\"],\"hardware_info\":[{\"hwtype\":\"IB-V825\"}]}}"

