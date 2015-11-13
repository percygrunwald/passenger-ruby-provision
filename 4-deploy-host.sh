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
    listen 80;
    server_name $DEPLOY_HOSTNAME;

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /var/www/$INPUT_USERNAME/public;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby $RUBY_COMMAND;
    rails_env production;
}

server {
    listen 80;
    server_name nowwwdomain.com;
    return 301 http://$DEPLOY_HOSTNAME$request_uri;
}
EOF
sudo nano /etc/nginx/sites-enabled/$INPUT_USERNAME.conf
sudo service nginx restart