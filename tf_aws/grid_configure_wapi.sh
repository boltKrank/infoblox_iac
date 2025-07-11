set -x

USERNAME=$1
PASSWORD=$2
GM_PUBLIC_IP=$3
GM_PRIVATE_IP=$4
WAPI_VERSION=$5

echo "Waiting for grid master..."
      for i in {1..20}; do
        if curl -k -u $USERNAME:$PASSWORD https://$GM_PUBLIC_IP/wapi/$WAPI_VERSION/grid >/dev/null 2>&1; then
          echo "Grid master is up"
          break
        fi
        sleep 10
      done

      echo "Downloading GM cert and Token"

      curl -k -u $USERNAME:$PASSWORD -H "Content-Type: application/json" -X POST "https://$GM_PUBLIC_IP/wapi/$WAPI_VERSION/fileop?_function=downloadcertificate" -d '{"certificate_usage": "ADMIN", "member":"infoblox.localdomain"}' > temp/gm_cert.json

      echo "Extracting token and cert"
      cat temp/gm_cert.json | jq -r '.token' > temp/token.txt
      cat temp/gm_cert.json | jq -r '.url' > temp/cert_url.txt
      temp/ip_replace.sh $GM_PRIVATE_IP $GM_PUBLIC_IP < temp/cert_url.txt > temp/public_cert_url.txt
      cat temp/public_cert_url.txt
      curl -k -u $USERNAME:$PASSWORD -H "content-type: application/force-download" "$(cat temp/public_cert_url.txt)" > temp/grid_master.crt
      
