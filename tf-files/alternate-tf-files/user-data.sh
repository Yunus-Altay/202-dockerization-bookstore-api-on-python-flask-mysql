#!/bin/bash
dnf update -y
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
newgrp docker
curl -SL https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /home/ec2-user/bookstore-api
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # change the token
FOLDER="https://$TOKEN@raw.githubusercontent.com/Yunus-Altay/bookstore-api-repo/main/"
curl -s --create-dirs -o "/home/ec2-user/bookstore-api/bookstore-api.py" -L "$FOLDER"bookstore-api.py
curl -s --create-dirs -o "/home/ec2-user/bookstore-api/requirements.txt" -L "$FOLDER"requirements.txt
curl -s --create-dirs -o "/home/ec2-user/bookstore-api/Dockerfile" -L "$FOLDER"Dockerfile
curl -s --create-dirs -o "/home/ec2-user/bookstore-api/docker-compose.yaml" -L "$FOLDER"docker-compose.yaml
cd /home/ec2-user/bookstore-api
echo ${db_password} > db_password.txt # do not forget to adjust the python file
echo ${db_root_password} > db_root_password.txt # # do not forget to adjust the python file
docker-compose up -d