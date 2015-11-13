#!/usr/bin/env bash

# Set INPUT_USERNAME to first argument ($1)
INPUT_USERNAME=$1

sudo adduser $INPUT_USERNAME \
	--system \
	--shell /bin/bash \
	--gecos "" \
	--group \
	--disabled-password 

sudo mkdir -p /home/$INPUT_USERNAME/.ssh
sudo sh -c "cat $HOME/.ssh/authorized_keys >> /home/$INPUT_USERNAME/.ssh/authorized_keys"
sudo chown -R $INPUT_USERNAME: /home/$INPUT_USERNAME/.ssh
sudo chmod 700 /home/$INPUT_USERNAME/.ssh
sudo sh -c "chmod 600 /home/$INPUT_USERNAME/.ssh/*"

sudo mkdir -p /var/www/$INPUT_USERNAME
sudo chown -R $INPUT_USERNAME: /var/www/$INPUT_USERNAME

sudo -u $INPUT_USERNAME -H git init --bare /home/$INPUT_USERNAME/$INPUT_USERNAME.git

# Copy bashrc and deploy script to new user's home
echo "Copying deploy script to /home/$INPUT_USERNAME"
sudo cp ~/.profile /home/$INPUT_USERNAME
sudo cp ~/.bashrc /home/$INPUT_USERNAME
sudo cp ~/*.sh /home/$INPUT_USERNAME
sudo chown $INPUT_USERNAME: /home/$INPUT_USERNAME/.profile
sudo chown $INPUT_USERNAME: /home/$INPUT_USERNAME/.bashrc
sudo chown $INPUT_USERNAME: /home/$INPUT_USERNAME/*.sh
sudo chmod +x /home/$INPUT_USERNAME/*.sh

# Now log out and push git repo to new user's home directory ~/username.git
# After pushing to the git repo, log in as new user and
# $ > ~/4-deploy-app
