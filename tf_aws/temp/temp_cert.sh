IP=$1

curl -k -u admin:Infoblox@312 -X POST \
  "https://$IP/wapi/v2.10/grid?_function=generate_certificate" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "CN=infoblox.localdomain",
    "validity": 730
  }'
