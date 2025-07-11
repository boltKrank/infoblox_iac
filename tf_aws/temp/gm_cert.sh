USERNAME=$1
PASSWORD=$2
#GRID_MASTER_IP=$3
GRID_MASTER_HOSTNAME=$4
# Usage: ./gm_cert.sh <username> <password> <grid_master_ip> <grid_master_hostname>

curl -k -u $USERNAME:$PASSWORD -H "Content-Type: application/json" -X POST \
  "https://3.104.217.47/wapi/v2.11/fileop?_function=downladcertificate" \
  -d '{
    "certificate_usage": "ADMIN",
    "member":"infoblos.localdomain",
  }'

  
# curl -k -u <username>:<password> -H "content-type: application/force-download" \
#  "<download_url_from_previous_response>"