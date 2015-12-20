#!/usr/bin/env bash

INPUT_USERNAME=`whoami`

cd /var/www/$INPUT_USERNAME

git --work-tree=/var/www/$INPUT_USERNAME \
--git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout develop -f

RAILS_ENV=development bundle install --path vendor --deployment

# Added security
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml

cp .env.example .env
RAKE_SECRET=`bundle exec rake secret`
echo "SECRET_KEY_BASE=$RAKE_SECRET" >> .env
nano .env
RAILS_ENV=staging bundle exec rake assets:precompile db:migrate

# Add post-receive hook for git
cat << EOF | tee /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive
#!/bin/bash
export PATH="\$HOME/.rbenv/bin:\$PATH"
eval "\$(rbenv init -)"
git --work-tree=/var/www/$INPUT_USERNAME --git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout develop -f
(cd /var/www/$INPUT_USERNAME && \\
RAILS_ENV=development bundle install --path vendor --deployment --without development test && \\
RAILS_ENV=staging bundle exec rake assets:precompile db:migrate && \\
chmod 700 config db && chmod 600 config/database.yml config/secrets.yml)
passenger-config restart-app /var/www/$INPUT_USERNAME
EOF
chmod 755 /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive