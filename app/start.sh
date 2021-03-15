#!/bin/bash

sudo yum install -y nodejs docker git
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo service docker start

sudo docker-compose up -d --build