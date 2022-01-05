#!/bin/bash

# We will build and install Python 3.9.9 from sources.

# download and unzip
workdir=$(pwd)
wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
tar zxvf Python-3.9.9.tgz
rm Python-3.9.9.tgz

# config and make
cd $workdir/Python-3.9.9
./configure --with-ensurepip=install --enable-optimizations 
make -j8

# install and update alternatives
# note: we do not make python3 the system default when calling python, 
# because it breaks a lot of stuff in the debian system that expectes
# python to link to python2.7
sudo make altinstall
sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 40
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 50
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.5 30
cd ..
sudo rm -rf Python-3.9.9

# update pip
sudo pip3.9 install -U pip

# set up initial virtual environment
python3.9 -m venv $workdir/venv_otree
source $workdir/venv_otree/bin/activate


# add virtualenv to login default
echo "source $workdir/venv_otree/bin/activate" >> $workdir/.otree_env
echo "source $workdir/.otree_env" >> $workdir/.bashrc