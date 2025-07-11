GM_IP=$1
MEMBER_MASTER=$2

curl -k -u admin:Infoblox@312 \
  -H "content-type: application/json" \
  -X POST "https://$MEMBER_MASTER/wapi/v2.12/grid?_function=join&_return_as_object=1" \
  -d "{\"grid_name\":\"Infoblox\", \
       \"master\":\"$GM_IP\", \
       \"shared_secret\":\"test\"}"


