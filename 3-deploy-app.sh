#!/usr/bin/env bash

INPUT_USERNAME=`whoami`

./1.1-install-rbenv.sh

cd /var/www/$INPUT_USERNAME

git --work-tree=/var/www/$INPUT_USERNAME --git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout master -f

bundle install --path vendor --deployment --without development test

# Added security
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml

RAILS_ENV=production bundle exec rake assets:precompile db:migrate

# Add post-receive hook for git
cat << EOF | tee /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive
#!/bin/bash
git --work-tree=/var/www/$INPUT_USERNAME --git-dir=/home/$INPUT_USERNAME/$INPUT_USERNAME.git checkout master -f
(cd /var/www/$INPUT_USERNAME && \\
	bundle install --path vendor --deployment --without development test && \\
	RAILS_ENV=production bundle exec rake assets:precompile db:migrate && \\
	chmod 700 config db && chmod 600 config/database.yml config/secrets.yml)
passenger-config restart-app /var/www/$INPUT_USERNAME
EOF
chmod 755 /home/$INPUT_USERNAME/$INPUT_USERNAME.git/hooks/post-receive