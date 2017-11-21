#!/usr/bin/env bash

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/LondonAppDeveloper/byob-profiles-rest-api.git'

PROJECT_BASE_PATH='/usr/local/apps'
VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install Python, SQLite and pip
apt-get update
apt-get install -y python3-dev sqlite python-pip supervisor nginx git

# Upgrade pip to the latest version.
pip install --upgrade pip
pip install virtualenv

mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH/profiles-rest-api

mkdir -p $VIRTUALENV_BASE_PATH
virtualenv  $VIRTUALENV_BASE_PATH/profiles_api

source $VIRTUALENV_BASE_PATH/profiles_api/bin/activate
pip install -r $PROJECT_BASE_PATH/profiles-rest-api/requirements.txt

# Run migrations
cd $PROJECT_BASE_PATH/profiles-rest-api/src

# Setup Supervisor to run our uwsgi process.
cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
