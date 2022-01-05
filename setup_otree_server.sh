#!/bin/bash
#
# This script is supposed to be run on a clean ubuntu 20.04 installation.
# You need git and setup git. Additionally, git clone https://github.com/GuangtengMeng/otree_setup_scripts.git
#
# For the oTree server setup, we need the following software:
# Python 3.9
# PostgreSQL
# Redis
# Supervisor
# Nginx
#
# The first three make sure oTree works well.
# Supervisor keeps the Webserver alive, i.e. restarts on reboot, crash etc.
# Nginx serves as a reverse proxy to be able to handle HTTPS requests.
# 
# I have separated the installation in different scripts.
# They will ask for sudo authentification at various times. I actively decided against running the scripts
# with root priveleges in their entirety. 
#
# Todo: Write a script that is run on first login, which promts the user to change their
# oTree web frontent admin password. Currently it is set to the rather insecure "awiotreeexperimente".
#

# first we set up the user accounts. We want to use sudo and avoid working as root as much as possible

# We want to be able to restart the Supervisor service from a script
# so we add a group that is allowed to do so w/o password.

# update packages list and install required software
sudo apt update
sudo apt upgrade
sudo apt install software-properties-common
sudo apt install libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm zlib1g-dev libssl-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev postgresql postgresql-contrib redis-server git supervisor nginx sudo

# create otree user
adduser otree

# add him to sudo group.
# we will undo this later to lock down the user.
adduser otree sudo


# prepare sudoers file for the time when we have removed the otree user from the sudo group
tmp=$(pwd)/.tmp_req
cat <<EOF > $tmp
# allow otree user to start, stop and restart supervisor
otree ALL=NOPASSWD:/usr/sbin/service supervisor start
otree ALL=NOPASSWD:/usr/sbin/service supervisor stop
otree ALL=NOPASSWD:/usr/sbin/service supervisor restart
EOF

# move sudo file in place
mv $tmp /etc/sudoers.d/otree_supervisor

# move scripts to user's home folder
# unzip otree_setup_scripts.zip
mv *.sh /home/otree/
chmod +x /home/otree/*.sh 
chown otree:otree /home/otree/*.sh


echo "To continue installation, login as user oTree with the password you just set."
echo "Then, run ./1_continue_setup.sh to continue the installation _without_ setting up SSL certificates."
echo "Alternatively, run ./1_continue_setup_ssl.sh to continue the installation _with_ SSL certificates."