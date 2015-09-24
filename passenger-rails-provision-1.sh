# Prepare the system
# Add keys for Passenger and RVM repos
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'

sudo apt-get update

# Install Packages
sudo apt-get install -y curl gnupg build-essential \
apt-transport-https ca-certificates \
nginx-extras passenger git \
nodejs && sudo ln -sf /usr/bin/nodejs /usr/local/bin/node

# Install RVM
curl -sSL https://get.rvm.io | sudo bash -s stable
sudo usermod -a -G rvm `whoami`

# Set proper paths in nginx and restart
pass_root=`passenger-config --root` && sudo sed -i "s,\# passenger_root .*;,passenger_root $pass_root;,g" /etc/nginx/nginx.conf
sudo sed -i 's,# passenger_ruby,passenger_ruby,g' /etc/nginx/nginx.conf
sudo sed -i 's,# gzip,gzip,g' /etc/nginx/nginx.conf
sudo service nginx restart