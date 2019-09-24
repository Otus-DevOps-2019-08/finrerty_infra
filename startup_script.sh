#!/bin/bash
echo "Ruby installation in progress..."
sudo apt update
sudo apt install ruby-full ruby-bundler build-essential -y
echo "MongoDB installation in progress..."
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
echo "Application Deployment in progress..."
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

