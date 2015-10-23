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

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

INPUT_USERNAME=$1
DEPLOY_HOSTNAME=$2

cd /var/www/$INPUT_USERNAME
rvm install ruby
rvm use ruby
gem install bundle

sudo chmod 755 config
RAKE_SECRET=`bundle exec rake secret`
sudo chmod 700 config

# Add nginx configuration
RUBY_COMMAND=`passenger-config about ruby-command | grep Nginx | cut -d ':' -f 2 | cut -d ' ' -f 3`
cat << EOF | sudo tee /etc/nginx/sites-enabled/$INPUT_USERNAME.conf
server {
    listen 80;
    server_name $DEPLOY_HOSTNAME;

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /var/www/$INPUT_USERNAME/public;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby $RUBY_COMMAND;
    passenger_env_var DATABASE_USERNAME root;
    passenger_env_var DATABASE_PASSWORD secret;
    passenger_env_var DATABASE_DB example;
    passenger_env_var DATABASE_HOST localhost;
    passenger_env_var SECRET_KEY_BASE $RAKE_SECRET;
}
EOF
sudo nano /etc/nginx/sites-enabled/$INPUT_USERNAME.conf
sudo service nginx restart