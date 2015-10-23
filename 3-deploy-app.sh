#!/usr/bin/env bash
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

INPUT_USERNAME=`whoami`

cd /var/www/$INPUT_USERNAME

git --work-tree=/var/www/$INPUT_USERNAME --git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout master -f

# Get ruby version from .ruby-version
if [[ -s "./.ruby-version" ]] ; then
  RUBY_VERSION=`cat ./.ruby-version`
else
  RUBY_VERSION='ruby'
fi

rvm install $RUBY_VERSION
rvm use $RUBY_VERSION
gem install bundler --no-rdoc --no-ri
bundle install --path vendor --deployment --without development test

# Added security
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml

RAILS_ENV=production bundle exec rake assets:precompile db:migrate

# Add post-receive hook for git
cat << EOF | tee /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive
#!/bin/bash
# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi
git --work-tree=/var/www/$INPUT_USERNAME --git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout master -f
(cd /var/www/$INPUT_USERNAME && \\
	bundle install --path vendor --deployment --without development test && \\
	RAILS_ENV=production bundle exec rake assets:precompile db:migrate && \\
	chmod 700 config db && chmod 600 config/database.yml config/secrets.yml)
passenger-config restart-app /var/www/$INPUT_USERNAME
EOF
chmod 755 /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive