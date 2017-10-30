# passenger-ruby-provision
A shell script that installs Phusion Passenger and RVM. Run the script on a cloud server and be ready to deploy.

## Deploy

1. Provision cloud server

2. SCP files to server

```bash
scp ./*.sh my-server:~
```

3. Provision the server with script 1

```bash
./1-passenger-ruby-provision.sh  
```

4. Uncomment Phusion passenger config line in nginx.conf

```bash
sudo vi /etc/nginx/nginx.conf
```

5. Add app user

```bash
./2-add-sandboxed-user.sh tn_prod
```

```bash
./2-add-sandboxed-user.sh tn_staging
```

6. Install rbenv and ruby 2.3 for app user and log out (logout is necessary to get the rbenv shim active)

```bash
ssh tn_prod@tn-prod
./1.1-install-rbenv.sh
logout
```

```bash
ssh tn_staging@tn-staging
./1.1-install-rbenv.sh
logout
```

7. Push code to git repo on server (no `post-receive` hook is active yet)

```bash
git remote add prod tn_prod@tn-prod:~/tn_prod.git
git push prod master
```

```bash
git remote add staging tn_staging@tn-staging:~/tn_staging.git
git push staging staging
```

8. Deploy app as new app user

```bash
ssh tn_prod@tn-prod
./3-deploy-app.sh
logout
```

```bash
ssh tn_staging@tn-staging
./3-deploy-app-staging.sh
logout
```

9. Deploy host to nginx as sudoer and edit the `rails_env` setting to match the env

```bash
ssh tn-prod
./4-deploy-host.sh tn_prod www.taiwannights.com
```

```bash
ssh tn-staging
./4-deploy-host.sh tn_staging staging.taiwannights.com
```

10. Install certs with `letsencrypt` (select option 2: standalone) (( make sure the DNS is configured ))

```bash
ssh tn-prod
~/letsencrypt/letsencrypt-auto certonly -d taiwannights.com -d www.taiwannights.com
```

```bash
ssh tn-staging
~/letsencrypt/letsencrypt-auto certonly -d staging.taiwannights.com
```

11. Edit the `./5-renew-certs.sh` to match the domains from the previous step

```bash
nano ./5-renew-certs.sh
```

Certs can be renewed in future by running

```bash
./5-renew-certs.sh
```

12. Restart `nginx`

```bash
sudo service nginx restart
``` 
