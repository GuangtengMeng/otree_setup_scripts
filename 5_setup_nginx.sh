#!/bin/bash
# setup nginx reverse proxy for otree
# This script does not setup ssl certificates / ssl encrypted connections through nginx


# dirs
tmp=$(pwd)/.nginx_tmp


# prepare nginx config
cat <<EOF > $tmp
map \$http_upgrade \$connection_upgrade {
	default   upgrade;
	''        close;
}

server {
	listen 80;
	server_name _;

	location / {
		proxy_pass http://localhost:8000;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_set_header X-Forwarded-Port \$server_port;
		proxy_set_header Host \$host;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header        Connection \$connection_upgrade;
		proxy_set_header        X-Real-IP \$remote_addr;
		proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header        X-Forwarded-Host \$server_name;
	}
}
EOF

# remove default nginx config
sudo rm /etc/nginx/sites-enabled/default
# move otree config in place
sudo mv $tmp /etc/nginx/sites-enabled/otree
echo "Restarting nginx"
sudo service nginx restart