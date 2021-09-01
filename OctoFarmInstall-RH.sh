#!/bin/bash
VERSION=0.1

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

log_info "OctoFarm Installer Script for Red Hat and Alma/Rocky and other variants (does not work on Fedora!) This script should only be executed by a system user with sudo privileges. Do not run as root"
read -r -s -p $'Press enter to continue... ctrl+c to cancel'
echo
echo
# Update repositories and packages
log_info "Updating repositories and packages, please be patient"

	sudo dnf update -yq
	    if [ $? -ne 0 ]; then
        	log_error "Failed to update repositories and packages. Please investigate manually and retry" &&
            	exit 1
    	    else
        	log_success "Updates Succeeded!."
    	    fi

# Install dependencies
log_info "Installing Nodejs, GCC, Make and Git"
	sudo dnf install nodejs gcc make git -y
		if [ $? -ne 0 ]; then
                	log_error "Installation failed. Please investigate manually and retry" &&
                		exit 1
            	else
                	log_success "Installation successful!."
            	fi


# Prepare MongoDB repository
log_info "Preparing the MongoDB repository"
log_warning "Error checking disabled during this step. If there are any issues begin your troubleshooting here."
	echo '[mongodb-upstream]' | sudo tee -a  /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "name=MongoDB Upstream Repository >> /etc/yum.repos.d/mongodb-org-5.0.repo" | sudo tee -a /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "baseurl=https://repo.mongodb.org/yum/redhat/8Server/mongodb-org/5.0/x86_64/" | sudo tee -a  /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "enabled=1" | sudo tee -a /etc/yum.repos.d/mongodb-org-5.0.repo
	echo "gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" | sudo tee -a /etc/yum.repos.d/mogodb-org-5.0.repo
log_warning "Repository added and error checking is now re-enabled. If there are any issues please manually check this step."

# Install and enable MongoDB
log_info "Installing MongoDB, please be patient"
	sudo dnf install mongodb-org
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
# Open port 4000
log_info "Opening port 4000 on FirewallD"
	sudo firewall-cmd --add-port=4000/tcp %% sudo firewall-cmd --add-port=4000/udp && sudo firewall-cmd --add-port=4000/udp --permanent && sudo firewall-cmd --add-port=4000/tcp --permanent
		if [ $? -ne 0 ]; then
                	log_error "Failed to open up the firewall. Please investigate manually and retry" &&
                	exit 1
            	else
                	log_success "Fireall changes succeeded!."
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
