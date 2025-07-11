GRID_IP=$1
curl -k -u admin:Infoblox@312 \
  -H "content-type: application/json" \
  -X POST "https://$GRID_IP/wapi/v2.12/member?_return_as_object=1" \
  -d "{\"config_addr_type\":\"IPV4\", \
       \"platform\":\"VNIOS\",
       \"host_name\":\"member01.localdomain\", \
       \"vip_setting\":{\"subnet_mask\":\"255.255.255.0\", \
                        \"address\":\"10.32.2.20\", \
                        \"gateway\":\"10.32.2.1\"}}"

