#!/bin/bash

# generate database password
db_user=otree_user
db_pwd=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)

# get user input for otree admin pwd
read -p "Please set the otree webinterface admin password: " otree_pwd

#set work directories
wd=$(pwd)
tgt=$wd/.supconfig.tmp
profile=$wd/.otree_env

# create database
sudo -i -u postgres psql postgres -c "CREATE DATABASE django_db;"
sudo -i -u postgres psql postgres -c "CREATE USER $db_user WITH PASSWORD '$db_pwd';"
sudo -i -u postgres psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE django_db TO $db_user;"

# set environmental variables
cat <<EOF >> $profile
export DATABASE_URL="postgres://$db_user:$db_pwd@localhost/django_db"
export OTREE_ADMIN_PASSWORD="$otree_pwd"
export OTREE_PRODUCTION=1
export OTREE_AUTH_LEVEL=STUDY
EOF

# setup supervisor script
cat <<EOF > $tgt
[program:otree]
command=$wd/venv_otree/bin/otree runprodserver 8000
directory=$wd/oTree
stdout_logfile=$wd/otree-supervisor.log
stderr_logfile=$wd/otree-supervisor-errors.log
autostart=true
autorestart=true
environment=
    PATH="$wd/venv_otree/bin/:%(ENV_PATH)s",
    DATABASE_URL="postgres://$db_user:$db_pwd@localhost/django_db",
    OTREE_ADMIN_PASSWORD="$otree_pwd",
    OTREE_PRODUCTION=1,
	OTREE_AUTH_LEVEL=STUDY,
EOF
sudo mv $tgt /etc/supervisor/conf.d/otree.conf