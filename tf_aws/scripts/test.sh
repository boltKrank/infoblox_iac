#!/bin/zsh
set -x

curl -k -u admin:Infoblox@312 -X POST \
  "https://13.237.189.213/wapi/v2.13.5/grid?_function=generate_certificate" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "CN=infoblox.localdomain",
    "validity": 365,
    "regenerate_dns": true
  }'


#   https://13.237.189.213/wapi/v2.13.5/grid?_function=generate_certificate
