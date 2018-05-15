#!/bin/bash
# we continue installation of otree

# then run one after the other
./2_install_python36.sh
./3_setup_database.sh
./4_setup_git.sh
./5_setup_nginx.sh

# clean up
rm 1_continue_setup.sh 2_install_python36.sh 3_setup_database.sh 4_setup_git.sh 5_setup_nginx.sh 5_setup_nginx_ssl.sh

# remove otree user from sudo group
sudo deluser otree sudo