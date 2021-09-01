#!/bin/bash

# Update repositories and packages

	sudo dnf update -y

# Install dependencies

	sudo dnf install nodejs gcc make git -y

# Prepare MongoDB repository

	echo "[mongodb-upstream]" > /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "name=MongoDB Upstream Repository >> /etc/yum.repos.d/mongodb-org-5.0.repo" >> /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "baseurl=https://repo.mongodb.org/yum/redhat/8Server/mongodb-org/5.0/x86_64/" >> /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "enabled=1" >> /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" >> gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc

# Install and enable MongoDB

	sudo dnf install mongodb-org -y
	sudo systemctl enable mongod --now

# Install pm2

	sudo npm install pm2 -g

# Open port 4000

	sudo firewall-cmd --add-port=4000/tcp
	sudo firewall-cmd --add-port=4000/udp
    	sudo firewall-cmd --add-port=4000/udp --permanent
    	sudo firewall-cmd --add-port=4000/tcp --permanent


# Clone OctoFarm
	git clone --depth 1 https://github.com/OctoFarm/OctoFarm.git

# Install OctoFarm

	cd OctoFarm/
	npm start
	pm2 list

# Make OctoFarm persistent

	pm2 startup | grep -v PM2 | bash
	pm2 save

