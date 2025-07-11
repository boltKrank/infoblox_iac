REF=$1
curl -k -u admin:Infoblox@312 -H "Content-Type: application/json" -X PUT "https://3.106.24.131/wapi/v2.11/member/b25lLnZpcnR1YWxfbm9kZSQx:member01.localdomain" -d "{\"pre_provisioning\":{\"licenses\":[\"dns\",\"dhcp\",\"enterprise\",\"nios\"],\"hardware_info\":[{\"hwtype\":\"IB-V825\"}]}}"

