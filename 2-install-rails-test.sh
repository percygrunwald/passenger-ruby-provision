cd ~

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

# Install Ruby
rvm install ruby
rvm use ruby

# Instull Ruby Bundler and Rails
gem install bundler --no-rdoc --no-ri
gem install rails --no-rdoc --no-ri

# Load demo
sudo rm -rf /var/www/rails-test
sudo mkdir -p /var/www/rails-test
sudo chown -R `whoami`: /var/www/rails-test
rails new /var/www/rails-test --skip-bundle

# Set Ruby version and bundle install
cd /var/www/rails-test
rvm install 2.2.1
rvm use --ruby-version ruby-2.2.1
gem install bundler
bundle install --path vendor --without development test
bundle install --path vendor --deployment
rake_secret=`bundle exec rake secret`
sudo sed -i "s,secret_key_base:.*SECRET_KEY_BASE.*,secret_key_base: $rake_secret,g" /var/www/rails-test/config/secrets.yml
rails generate controller welcome index
sudo sed -i "s,\# root 'welcome#index',root 'welcome#index',g" /var/www/rails-test/config/routes.rb
bundle exec rake assets:precompile db:migrate

# Create test .conf for example app
cat << EOF | sudo tee /etc/nginx/sites-enabled/default
server {
    listen 80 default_server;

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /var/www/rails-test/public;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby /usr/bin/passenger_free_ruby;
}
EOF

sudo service nginx restart
