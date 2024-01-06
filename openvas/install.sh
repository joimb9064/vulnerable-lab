#!/bin/bash
mkdir openvas && cd openvas
#sudo usermod -aG docker $USER && su $USER
curl -f -L https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml -o docker-compose.yml
sudo docker-compose -f docker-compose.yml -p greenbone-community-edition up -d
#open the site http://127.0.0.1:9392 on your ubuntu machine
#Type username:admin password:admin
#Reference https://greenbone.github.io/docs/latest/22.4/container/index.html
