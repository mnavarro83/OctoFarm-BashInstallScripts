#!/bin/bash

#Variables
VERSION=0.1
IPADDR="$(hostname -I | awk '{print $1}')"

# Bash Colors
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
COLOR_DEFAULT="\e[39m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"
COLOR_MAGENTA="\e[35m"
COLOR_CYAN="\e[36m"

# Make that output pretty
function log_success() {
	echo -e "[$COLOR_GREEN"SUCCESS"$COLOR_DEFAULT] $1"
}
function log_info() {
	echo -e "[$COLOR_BLUE"INFO"$COLOR_DEFAULT] $1"
}
function log_warning () {
	echo -e "[$COLOR_YELLOW"WARNING"$COLOR_DEFAULT] $1"
}
function log_error() {
	echo -e "[$COLOR_RED"FAILED"$COLOR_DEFAULT] $1"
}

log_info "OctoFarm Installer Script for Debian/Canonical variants. Tested on Debian 10 and Ubuntu 21.04. This script should only be executed by a system user with sudo privileges. Do not run as root"
read -r -s -p $'Press enter to continue... ctrl+c to cancel'
echo
echo
# Update repositories and packages
log_info "Updating repositories and packages, please be patient"

	sudo apt update
	    if [ $? -ne 0 ]; then
        	log_error "Failed to update package lists. Please investigate manually and retry" &&
            	exit 1
        else
        	log_success "List Updates Succeeded!."
        fi
        
	sudo apt upgrade -y
	    if [ $? -ne 0 ]; then
        	log_error "Failed to update packages. Please investigate manually and retry" &&
            	exit 1
        else
        	log_success "Updates Succeeded!."
        fi

# Install dependencies
log_info "Setting up NodeJS LTS v14"
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        if [ $? -ne 0 ]; then
            log_error "NodeJS Installation failed. Please investigate manually and retry" &&
                exit 1
        else
            log_success "NodeJS Installation successful!."
        fi
log_info "Installing Nodejs, GCC, Make, NPM and Git and Gnupg"
	sudo apt -y install nodejs gcc make git npm gnupg
		if [ $? -ne 0 ]; then
            log_error "Installation failed. Please investigate manually and retry" &&
                exit 1
        else
            log_success "Installation successful!."
        fi


# Prepare MongoDB repository
log_info "Preparing the MongoDB repository"
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        if [ $? -ne 0 ]; then
            log_error "Repository preparation failed. Please investigate manually and retry" &&
                exit 1
        else
            log_success "Repository ready!."
        fi
        
log_info "Adding repository"
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        if [ $? -ne 0 ]; then
            log_error "Repository installation failed. Please investigate manually and retry" &&
                exit 1
        else
            log_success "MongoDB repository added successfully!."
        fi

# Install and enable MongoDB
sudo apt update
log_info "Installing MongoDB, please be patient"
	sudo apt -y install mongodb-org
		if [ $? -ne 0 ]; then
            log_error "Failed to install MongoDB. Please investigate manually and retry" &&
                exit 1
        else
            log_success "MongoDB successfully installed."
        fi

log_info "Starting and making MongoDB persist reboots"
	sudo systemctl enable mongod --now
		if [ $? -ne 0 ]; then
            log_error "Something appears to be wrong with the MongoDB system unit file. Please investigate manually and retry" &&
                exit 1
        else
            log_success "Success!"
        fi

# Install pm2
log_info "Installing pm2"
	sudo npm install pm2 -g
		if [ $? -ne 0 ]; then
                	log_error "Failed to install pm2. Please investigate manually and retry" &&
                	exit 1
            	else
                	log_success "Installation of pm2 successful!."
            	fi

# Clone OctoFarm
log_info "Cloning OctoFarm"
	git clone --depth 1 https://github.com/OctoFarm/OctoFarm.git
		if [ $? -ne 0 ]; then
                	log_error "Unable to clone. Please investigate manually and retry" &&
                	exit 1
            	else
                	log_success "Clone Succeeded!."
            	fi
# Install OctoFarm
log_info "Installing and starting up OctoFarm"

	cd OctoFarm/ && npm start
		if [ $? -ne 0 ]; then
                	log_error "Did not start successfully. Please investigate manually and retry" &&
                	exit 1
            	else
                	log_success "Startup Succeeded!."
            	fi
# Make OctoFarm persistent
log_info "Making OctoFarm persistent"
	pm2 startup | grep -v PM2 | bash && pm2 save
		if [ $? -ne 0 ]; then
                	log_error "Something went wrong. Please investigate manually and retry" &&
                	exit 1
            	else
                	log_success "Updates Succeeded!."
           	fi
echo
echo
log_success "OctoFarm is now installed. You will need to open up port 4000 on the firewall (if enabled). Please navigate to '$IPADDR:4000' to create a user and finalize setup once the port is open"
echo
echo
log_success "Have a day!"
exit 0
