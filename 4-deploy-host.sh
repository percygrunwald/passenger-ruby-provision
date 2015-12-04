#!/usr/bin/env bash
if [ -z "$1" ]
  then
    echo "No app user supplied, please call like:"
    echo './script %appuser% %hostname%'
    exit
fi

if [ -z "$2" ]
  then
    echo "No hostname supplied, please call like:"
    echo './script %appuser% %hostname%'
    exit
fi

INPUT_USERNAME=$1
DEPLOY_HOSTNAME=$2

cd /var/www/$INPUT_USERNAME
sudo chmod 700 config

# Add nginx configuration
RUBY_COMMAND="/home/$INPUT_USERNAME/.rbenv/shims/ruby"
cat << EOF | sudo tee /etc/nginx/sites-enabled/$INPUT_USERNAME.conf
server {
    server_name $DEPLOY_HOSTNAME;

    listen 443 ssl spdy;
    listen [::]:443 ssl spdy;
    ssl_certificate /etc/letsencrypt/live/$DEPLOY_HOSTNAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DEPLOY_HOSTNAME/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # openssl dhparam -out dhparam.pem 2048
    ssl_dhparam /etc/nginx/dhparam.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security max-age=15768000;

    ssl_stapling on;
    ssl_stapling_verify on;

    ## verify chain of trust of OCSP response using Root CA and Intermediate certs
    #ssl_trusted_certificate /path/to/root_CA_cert_plus_intermediates;
    ssl_trusted_certificate /etc/letsencrypt/live/$DEPLOY_HOSTNAME/chain.pem;
    resolver 8.8.8.8 8.8.4.4 valid=86400;
    resolver_timeout 10;

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /var/www/$INPUT_USERNAME/public;

    client_max_body_size 21M;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby $RUBY_COMMAND;
    rails_env production;
}

server {
    server_name $DEPLOY_HOSTNAME;
    listen 80;
    return 301 http://\$servername\$request_uri;
}
EOF
sudo nano /etc/nginx/sites-enabled/$INPUT_USERNAME.conf
echo "Now get certs from ~/letsencrypt/letsencrypt-auto certonly -d domain.com -d www.domain.com"