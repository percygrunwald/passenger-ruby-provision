#!/usr/bin/env bash
sudo service nginx stop
~/letsencrypt/letsencrypt-auto certonly -d www.example.com
sudo service nginx start