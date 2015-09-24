if [ -z "$1" ]
  then
    echo "No username supplied, please call like:"
    echo './script %username%'
    exit
fi

INPUT_USERNAME=$1
sudo adduser $INPUT_USERNAME \
	--system \
	--shell /bin/bash \
	--gecos "" \
	--group \
	--disabled-password 
sudo usermod -a -G rvm $INPUT_USERNAME
sudo mkdir -p /home/$INPUT_USERNAME/.ssh
sudo sh -c "cat $HOME/.ssh/authorized_keys >> /home/$INPUT_USERNAME/.ssh/authorized_keys"
sudo chown -R $INPUT_USERNAME: /home/$INPUT_USERNAME/.ssh
sudo chmod 700 /home/$INPUT_USERNAME/.ssh
sudo sh -c "chmod 600 /home/$INPUT_USERNAME/.ssh/*"
sudo mkdir -p /var/www/$INPUT_USERNAME
sudo chown -R $INPUT_USERNAME: /var/www/$INPUT_USERNAME
sudo -u $INPUT_USERNAME -H git init --bare /home/$INPUT_USERNAME/$INPUT_USERNAME.git