#!/usr/bin/env bash
if [ -z "$1" ]
  then
    echo "No username supplied, please call like:"
    echo './script %username%'
    exit
fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

# Set INPUT_USERNAME to first argument ($1)
INPUT_USERNAME=$1

sudo adduser $INPUT_USERNAME \
	--system \
	--shell /bin/bash \
	--gecos "" \
	--group \
	--disabled-password 

# Install some rubies
rvm install ruby
rvm install 2.2.2
rvm install 2.2.3

# Add new user to RVM group so that rvm can be used
sudo usermod -a -G rvm $INPUT_USERNAME

sudo mkdir -p /home/$INPUT_USERNAME/.ssh
sudo sh -c "cat $HOME/.ssh/authorized_keys >> /home/$INPUT_USERNAME/.ssh/authorized_keys"
sudo chown -R $INPUT_USERNAME: /home/$INPUT_USERNAME/.ssh
sudo chmod 700 /home/$INPUT_USERNAME/.ssh
sudo sh -c "chmod 600 /home/$INPUT_USERNAME/.ssh/*"

sudo mkdir -p /var/www/$INPUT_USERNAME
sudo chown -R $INPUT_USERNAME: /var/www/$INPUT_USERNAME

sudo -u $INPUT_USERNAME -H git init --bare /home/$INPUT_USERNAME/$INPUT_USERNAME.git

# Copy deploy script to new user's home
echo "Copying deploy script to /home/$INPUT_USERNAME"
sudo cp ~/*deploy-app.sh /home/$INPUT_USERNAME
sudo chown $INPUT_USERNAME: /home/$INPUT_USERNAME/*.sh
sudo chmod +x /home/$INPUT_USERNAME/*.sh

# Now log out and push git repo to new user's home directory ~/username.git
# After pushing to the git repo, log in as new user and
# $ > ~/4-deploy-app
