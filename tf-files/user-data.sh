#!/bin/bash
hostnamectl set-hostname docker_instance
dnf update -y
dnf install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
# install docker-compose
curl -SL https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
dnf install git -y
cd /home/ec2-user && git clone https://github.com/Yunus-Altay/202-dockerization-bookstore-api-on-python-flask-mysql.git
cd /home/ec2-user/202-dockerization-bookstore-api-on-python-flask-mysql
# echo ${db_password} > db_password.txt
# echo ${db_root_password} > db_root_password.txt
docker-compose up -d