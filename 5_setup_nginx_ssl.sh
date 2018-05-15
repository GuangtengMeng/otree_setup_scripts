#!/bin/bash
# setup nginx reverse proxy for otree
# This script asks for paths to the SSL certificates to use
# if non are provided, or if they are invalid, it uses self signed certs
# these are NOT FOR USE IN PRODUCTION.
#


# dirs
tmp=$(pwd)/.nginx_tmp

# Get SSL Certificate paths
echo "Please provide paths to the SSL certificate files."
echo "Default will be self-signed cert. Do not use for production!"
read -p "SSL Certificate pem: " ssl_cert
read -p "SSL Certificate key: " ssl_key

if [ ! -e "$ssl_cert" ] || sudo [ ! -e "$ssl_key" ];
	then
		echo "The files are not valid. Using self-signed certs."
		ssl_cert="/etc/ssl/certs/ssl-cert-snakeoil.pem"
		ssl_key="/etc/ssl/private/ssl-cert-snakeoil.key"
	else
		echo "Valid files provided. Setting certificate."
fi


# prepare nginx config
cat <<EOF > $tmp
map \$http_upgrade \$connection_upgrade {
	default   upgrade;
	''        close;
}

server {
	listen 80;
	server_name _;
	return 301 https://\$server_name\$request_uri;
}

server {
	listen 443 ssl;
	server_name _;

	ssl_certificate $ssl_cert;
	ssl_certificate_key $ssl_key;

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