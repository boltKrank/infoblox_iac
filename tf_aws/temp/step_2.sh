GM_IP=$1

curl -k -u admin:Infoblox@312 -H "content-type: application/json" \
  -X POST "https://$GM_IP/wapi/v2.12/grid?_function=join&_return_as_object=1" \
  -d "{\"grid_name\":\"Infoblox\",\"master\":\"10.32.2.10\",\"shared_secret\":\"test\"}"

