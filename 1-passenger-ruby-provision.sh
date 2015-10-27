#!/usr/bin/env bash
# Prepare the system
# Add keys for Passenger and RVM repos
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
sudo add-apt-repository "deb http://mirrors.hustunique.com/mariadb/repo/10.1/ubuntu trusty main" && \

# Update repos and upgrade
sudo apt-get update
sudo apt-get upgrade -qq

# Set automatic security updates
cat << EOF | sudo tee /etc/apt/apt.conf.d/50unattended-upgrades 
// Automatically upgrade packages from these (origin:archive) pairs
Unattended-Upgrade::Allowed-Origins {
        "\${distro_id}:\${distro_codename}-security";
};
Unattended-Upgrade::Package-Blacklist {};
EOF

cat << EOF | sudo tee /etc/apt/apt.conf.d/*periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Install Packages
sudo apt-get install -y --fix-missing language-pack-en curl gnupg build-essential \
git-core curl zlib1g-dev libssl-dev libreadline-dev \
libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev \
python-software-properties libffi-dev \
apt-transport-https ca-certificates \
nginx-extras passenger git \
mariadb-server libmariadbd-dev imagemagick libgmp3-dev \
nodejs && sudo ln -sf /usr/bin/nodejs /usr/local/bin/node

# Install rbenv, ruby and bundler
./1.1-install-rbenv.sh

# Set proper paths in nginx and restart
PASS_ROOT=`passenger-config --root`
INPUT_USERNAME=`whoami`
sudo sed -i "s,\# passenger_root .*;,passenger_root $PASS_ROOT;,g" /etc/nginx/nginx.conf
sudo sed -i "s,\# passenger_ruby .*,passenger_ruby /home/$INPUT_USERNAME/.rbenv/shims/ruby;,g" /etc/nginx/nginx.conf
sudo sed -i 's,# gzip,gzip,g' /etc/nginx/nginx.conf
sudo service nginx restart

# Reboot so that upgraded packages come into effect
sudo reboot