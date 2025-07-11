USERNAME=$1
PASSWORD=$2
MEMBER_IP=$3
GRID_MASTER_IP=$4
SHARED_SECRET=$5

# Example: ./initiate_member_join.sh admin Infoblox@312 13.55.64.78 10.32.2.10 test

curl -k -u $USERNAME:$PASSWORD \
  -H "content-type: application/json" \
  -X POST "https://$MEMBER_IP/wapi/v2.12/grid?_function=join&_return_as_object=1" \
  -d "{\"grid_name\":\"Infoblox\", \
      \"master\":\"$GRID_MASTER_IP\", \
      \"shared_secret\":\"$SHARED_SECRET\"}"

