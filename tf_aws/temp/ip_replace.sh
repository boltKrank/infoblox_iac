set -x 

old_ip="$1"
new_ip="$2"

sed "s|https://$old_ip|https://$new_ip|"

